pragma Singleton
import QtQuick

QtObject {
	property bool doNotDisturb: false
	property bool idleInhibited: false
	property bool notificationCenterOpen: false
	property int messageCount: 0
	property list<QtObject> newMessages
	property list<QtObject> centerMessages
}
