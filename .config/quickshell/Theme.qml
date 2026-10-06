pragma Singleton
import QtQuick
import ".."

QtObject {
	readonly property int radius: 8
	readonly property int width: 3

	property QtObject colors: ThemeColors {}
    readonly property color background: colors ? colors.background : "#BB2A39"
    readonly property color accent: colors ? colors.accent : "#FE7446"
    readonly property color alternate: colors ? colors.alternate : "#282828"
    readonly property color border: colors ? colors.border : "#31342B"
    readonly property color primary: colors ? colors.primary : "#5CBD88"
    readonly property color primaryTransparent: colors ? colors.primaryTransparent : "#B05CBD88"
    readonly property color secondary: colors ? colors.secondary : "#6167AD"
    readonly property color secondaryTransparent: colors ? colors.secondaryTransparent : "#B06167AD"
    readonly property color text: colors ? colors.text : "#ffffff"
    readonly property color alternatetext: colors ? colors.alternatetext : "#000000"
}
