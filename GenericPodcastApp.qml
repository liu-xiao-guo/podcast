import QtQuick 2.0
import Ubuntu.Components 0.1
import QtQuick.XmlListModel 2.0
import Ubuntu.Components.ListItems 0.1 as ListItem
import QtMultimedia 5.0

PageStack {
    id: ps
    Component.onCompleted: ps.push(front)

    property alias squareLogo: logo.source
    property alias author: author.text
    property alias category: category.text
    property alias name: front.title
    property alias description: desc.text
    property alias feed: rssmodel.source

    Action {
        id: reloadAction
        text: "Reload"
        iconName: "reload"
        onTriggered: rssmodel.reload()
    }

    Page {
        id: front
        visible: true

        tools: ToolbarItems {
            ToolbarButton {
                action: reloadAction
            }
        }

        Flickable {
            anchors.fill: parent
            contentHeight: row.height + desc.height + showlist.height + desc.anchors.topMargin + showlist.anchors.topMargin

            Row {
                id: row
                width: parent.width
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.topMargin: units.gu(1)
                anchors.leftMargin: units.gu(1)
                anchors.rightMargin: units.gu(1)
                spacing: units.gu(2)

                UbuntuShape {
                    id: logoshape
                    width: parent.width / 3
                    height: parent.width / 3
                    image: Image {
                        id: logo
                        fillMode: Image.PreserveAspectFit
                    }
                    ActivityIndicator {
                        running: logo.status != Image.Ready
                        anchors.centerIn: logoshape
                    }
                }

                Column {
                    width: row.width - row.spacing - row.anchors.leftMargin- row.anchors.rightMargin - logoshape.width
                    spacing: units.gu(1)
                    anchors.bottom: parent.bottom
                    Label {
                        id: author
                        fontSize: "small"
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                    Label {
                        id: category
                        wrapMode: Text.WordWrap
                        width: parent.width
                        fontSize: "small"
                    }
                }
            }

            Label {
                id: desc
                anchors.top: row.bottom
                anchors.left: parent.left
                anchors.topMargin: units.gu(2)
                anchors.leftMargin: row.anchors.leftMargin
                width: parent.width - (row.anchors.leftMargin * 2)
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                property bool expanded: false
                clip: true
                height: {
                    if (desc.contentHeight > units.gu(12) && !expanded) {
                        return units.gu(12)
                    }
                    return desc.contentHeight
                }

                Rectangle {
                    color: "black"
                    width: moretxt.contentWidth + units.gu(2)
                    height: moretxt.contentHeight
                    anchors.bottom: desc.bottom
                    anchors.right: desc.right
                    Label {
                        id: moretxt
                        color: "white"
                        anchors.centerIn: parent
                        text: desc.expanded ? "<<" : ">>"
                    }
                    visible: desc.contentHeight > units.gu(12)
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: desc.expanded = !desc.expanded
                }
            }

            Column {
                id: showlist
                anchors.top: desc.bottom
                anchors.topMargin: units.gu(2)
                width: parent.width
                Repeater {
                    model: rssmodel
                    ListItem.Standard {
                        text: title
                        width: parent.width
                        progression: true
                        onClicked: { ps.push(episode, {download: model.download, summary: model.summary, title: model.title}); }
                    }
                }
            }
            ActivityIndicator {
                anchors.top: desc.bottom
                anchors.topMargin: units.gu(2)
                height: reloadbutton.height
                width: height
                anchors.horizontalCenter: parent.horizontalCenter
                running: rssmodel.status != XmlListModel.Ready && rssmodel.status != XmlListModel.Error
            }
        }
    }

    Page {
        id: episode
        property string download
        property string summary
        visible: false

        Flickable {
            anchors.fill: parent
            contentHeight: biglogo.height + positionbar.height + buttons.height + epdesc.height + (epcol.spacing * 4)

            Column {
                id: epcol
                width: parent.width
                spacing: units.gu(2)

                Image {
                    id: biglogo
                    source: logo.source
                    width: parent.width
                    height: parent.width
                    fillMode: Image.PreserveAspectFit
                }

                Rectangle {
                    id: positionbar
                    width: buttons.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: units.gu(5)
                    color: "transparent"

                    Rectangle {
                        id: actualbar
                        width: parent.width
                        height: units.gu(0.5)
                        color: "#999999"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.centerIn: parent
                    }
                    Rectangle {
                        width: units.gu(0.5)
                        height: units.gu(2)
                        color: "#444444"
                        anchors.verticalCenter: actualbar.verticalCenter
                        x: actualbar.width * aud.position / aud.duration
                    }
                    MouseArea {
                        anchors.fill: parent
                        onPressed: {
                            aud.seek(aud.duration * mouse.x / actualbar.width)
                        }
                    }
                }

                Row {
                    id: buttons
                    spacing: units.gu(2)
                    anchors.horizontalCenter: parent.horizontalCenter
                    Button {
                        text: "<<30"
                        onClicked: aud.seek(aud.position - 30000)
                    }
                    Button {
                        text: aud.status == Audio.Loading ? "load" : (aud.playbackState == Audio.PlayingState ? "Stop" : "Play")
                        onClicked: {
                            aud.source = episode.download;
                            if (aud.playbackState == Audio.PlayingState) {
                                aud.pause();
                            } else {
                                aud.play();
                            }
                            console.log(aud.duration, aud.position);
                        }
                    }
                    Button {
                        text: "30>>"
                        onClicked: aud.seek(aud.position + 30000)
                    }

                }

                Label {
                    id: epdesc
                    width: parent.width - units.gu(4)
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: episode.summary
                    wrapMode: Text.Wrap
                    color: "white"
                    textFormat: Text.RichText
                }
            }
        }
    }

    XmlListModel {
        id: rssmodel
        query: "/rss/channel/item"
        namespaceDeclarations: "declare namespace itunes='http://www.itunes.com/dtds/podcast-1.0.dtd'; declare namespace content='http://purl.org/rss/1.0/modules/content/';"
        XmlRole { name: "title"; query: "title/string()" }
        XmlRole { name: "pubDate"; query: "pubDate/string()" }
        XmlRole { name: "download"; query: "enclosure/@url/string()" }
        XmlRole { name: "summary"; query: "content:encoded/string()" }
    }

    Audio {
        id: aud
    }
}

