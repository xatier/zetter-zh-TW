# Maintainer: BrLi <brli at chakralinux dot org>

pkgname=zettlr
pkgver=1.8.1
pkgrel=2
pkgdesc="A markdown editor for writing academic texts and taking notes"
arch=('x86_64')
url='https://www.zettlr.com'
license=('GPL' 'custom') # Noted that the icon and name are copyrighted
depends=(electron ttf-webhostinghub-glyphs otf-crimson-text)
makedepends=(yarn git gulp)
optdepends=('pandoc: For exporting to various format'
            'texlive-bin: For Latex support'
            'ttf-lato: Display output in a more comfortable way')
options=('!strip')
_commit=93273f39a0a178f82ad3c8ed64d01faf4224aab1 # 1.8.1^0
_lang=('de-DE' 'en-GB' 'en-US' 'fr-FR' 'ja-JP' 'zh-CN' 'es-ES' 'ru-RU')
source=(git+https://github.com/Zettlr/Zettlr.git#commit="${_commit}"
        # citation style
        https://github.com/citation-style-language/locales/archive/master.zip
        https://raw.githubusercontent.com/citation-style-language/styles/master/chicago-author-date.csl)
        # translations
for _l in ${_lang[@]}; do
    source+=(https://translate.zettlr.com/download/${_l}.json)
done

# zh-tw translation
source+=(
    'https://raw.githubusercontent.com/xatier/zetter-zh-TW/master/zh-TW.json'
    'https://raw.githubusercontent.com/xatier/zetter-zh-TW/master/zh_TW.patch'
)

sha256sums=('SKIP'
            'dea821e58120909dbe67c32d2a05a868c7ebc406c1d93e0b2cca56c82263e81a'
            '2b7cd6c1c9be4add8c660fb9c6ca54f1b6c3c4f49d6ed9fa39c9f9b10fcca6f4'
            '8578534647c46e8b9150a471cf1fa4e791cc2709562aa47fa4675a01faf37de7'
            '00866f9f4e327b9bbc3c8295b8245249ccb42939696aea97412db7a7725445f6'
            '7beea98f9ad078240297121a5d8c392ac187a77dc3484603d584ea8a16cb43a8'
            'ccfd645e08d8cb25acd867209773305dd29a224e0496b5c4f1412651e1406406'
            'b23b36607a8b0ebe35a59d9954e09cdb0e79b660ed8d96b8a18817aae09f061e'
            '1e6f2fa86679f1bbdb669acbc079b5b468a355ba1827f4ff8e81cba6148dc114'
            '8729104501d29682171c91cf8f095fa52967ef061dbaf7390fd57be88bd507bd'
            'c03aee051a159c32ad44ac6ead384343a0850112ba95663da2b390fd115806a4'
            '14b1534a8ab29eade7d6cdaf92f539dc2851e312e922ef5923b8566b1bc070d3'
            'f8756bfaa5dec00524f98e16097943c4901ed257aac36e556be1fc97631433e0')

prepare() {
    cd "${srcdir}/Zettlr"

    # We don't build electron and friends, and don't depends on postinstall script
    sed '/^\s*\"electron-notarize.*$/d;/^\s*\"electron-builder.*$/d;/postinstall/d' -i package.json
    sed 's/\^10.1.5/10.1.5/' -i package.json

    # lang:refresh from package.json
    for _l in ${_lang[@]}; do
        cp "${srcdir}/${_l}.json" source/common/lang/
    done

    # zh-tw translations
    cp "${srcdir}/zh-TW.json" source/common/lang/
    patch -p1 <"${srcdir}/zh_TW.patch"

    # csl:refresh from package.json
    cp $(find "${srcdir}/locales-master/" -name "*.xml") source/app/service-providers/assets/csl-locales/
    cp "${srcdir}/locales-master/locales.json" source/app/service-providers/assets/csl-locales/
    cp "${srcdir}/chicago-author-date.csl" source/app/service-providers/assets/csl-styles/

}

build() {
    cd "${srcdir}/Zettlr"
    local NODE_ENV=''
    yarn install --pure-lockfile \
                 --cache-folder "${srcdir}/cache" \
                 --link-folder "${srcdir}/link" \
                 --ignore-scripts
    yarn reveal:build

    cd "${srcdir}/Zettlr/source"
    yarn install --pure-lockfile --cache-folder "${srcdir}/cache"

    cd "${srcdir}/Zettlr"
    node node_modules/.bin/electron-forge make || true # always failed anyway, we just want the outcome .webpack directory

    cd "${srcdir}/Zettlr/.webpack"

    # remove fonts
    find . -type d -name "fonts" -exec rm -rfv {} +
}

# check() {
#     cd "${srcdir}/Zettlr"
#     # Require electron module to test
#     yarn add --cache-folder "${srcdir}/cache" --link-folder "${srcdir}/link" electron
#     # The "test" function in package.json
#     node node_modules/mocha/bin/mocha
#     # The "test-gui" function in package.json, not useful in our case
#     node scripts/test-gui.js
#     # Clean up
#     yarn remove electron
#     rm yarn.lock
#     rm node_modules/.bin -rf
# }

package() {
    local _destdir=usr/lib/"${pkgname}"
    install -dm755 "${pkgdir}/${_destdir}"

    cd "${srcdir}/Zettlr"

    # only copy the critical parts
    cp -r --no-preserve=ownership --preserve=mode ./package.json "${pkgdir}/${_destdir}/"
    cp -r --no-preserve=ownership --preserve=mode ./.webpack "${pkgdir}/${_destdir}/"

    install -Dm755 /dev/stdin "${pkgdir}/usr/bin/${pkgname}" <<END
#!/bin/sh
exec electron /${_destdir} "\$@"
END

    # install icons of various sizes to hi-color theme
    for px in 16 24 32 48 64 96 128 256 512; do
        install -Dm644 "${srcdir}/Zettlr/resources/icons/png/${px}x${px}.png" \
            "${pkgdir}/usr/share/icons/hicolor/${px}x${px}/apps/${pkgname}.png"
    done

    # generate freedesktop entry files
    install -Dm644 /dev/stdin "${pkgdir}/usr/share/applications/${pkgname}.desktop" <<END
[Desktop Entry]
Name=Zettlr
Comment=A powerful Markdown Editor with integrated tree view
Exec=${pkgname} %U
Terminal=false
Type=Application
Icon=${pkgname}
StartupWMClass=Zettlr
MimeType=text/markdown;
Categories=Office;
END

    # license
    install -Dm644 "${srcdir}/Zettlr/LICENSE" "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}
