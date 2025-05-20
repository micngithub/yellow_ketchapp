import QtQuick
import QtQuick.Controls
import QtProtobuf
import QtGrpc
import QtCore
import ClientQtQuick.Proto


Window {
    width: 400
    height: 300
    visible: true
    title: "QtProtobuf QML Client"

    GrpcHttp2Channel {
        id: grpcChannel
        hostUri: "http://localhost:50051"
    }

    GrpcCallOptions {
        id: grpcCallOptions
        deadlineTimeout: 6000
    }

    GreeterClient {
        id: greeter
        channel: grpcChannel.channel
    }

    ImageServiceClient {
        id: imageClient
        channel: grpcChannel.channel
    }

    property helloRequest req
    property imageListRequest listReq
    property imageRequest imageReq

    ListModel {
        id: imagesModel
    }

    // Q_INVOKABLE void SayHello(const imagestorage::HelloRequest &arg, const QJSValue &callback, const QJSValue &errorCallback, const QtGrpcQuickPrivate::QQmlGrpcCallOptions *options = nullptr);
    // Q_INVOKABLE void ListImages(const imagestorage::ImageListRequest &arg, const QJSValue &callback, const QJSValue &errorCallback, const QtGrpcQuickPrivate::QQmlGrpcCallOptions *options = nullptr);
    // Q_INVOKABLE void GetImage(const imagestorage::ImageRequest &arg, const QJSValue &callback, const QJSValue &errorCallback, const QtGrpcQuickPrivate::QQmlGrpcCallOptions *options = nullptr);


    function finishCallback(response: helloReply): void {
        greetingLabel.text = response.message
        console.log(response.message)
    }

    function errorCallback(error): void {
        console.log(
            `Error callback executed. Error message: "${error.message}" Code: ${error.code}`
        );
    }


    Column {
        anchors.centerIn: parent
        spacing: 6

        TextField {
            id: nameField
            placeholderText: "Name"
            width: parent.width * 0.7
        }

        Button {
            text: "Send"
            onClicked: {
                req.name = nameField.text
                greeter.SayHello(req, finishCallback, errorCallback, grpcCallOptions);
            }
        }

        Text {
            id: greetingLabel
            text: ""
        }

        Button {
            id: loadButton
            text: "Load Images"
            onClicked: {
                imageClient.ListImages(listReq, function(resp: imageListReply) {
                    imagesModel.clear()
                    for (let i = 0; i < resp.filenames.length; ++i)
                        imagesModel.append({ name: resp.filenames[i] })
                }, errorCallback, grpcCallOptions)
            }
        }

        ListView {
            id: imageList
            width: parent.width * 0.7
            height: 120
            model: imagesModel
            delegate: Text {
                text: name
            }
        }

        Button {
            text: "Download Selected"
            onClicked: {
                if (imageList.currentIndex < 0)
                    return
                imageReq.filename = imagesModel.get(imageList.currentIndex).name
                imageClient.GetImage(imageReq, function(resp: imageData) {
                    var path = "downloads/" + imageReq.filename
                    if (fileWriter.save(path, resp.data))
                        console.log("Saved to " + path)
                }, errorCallback, grpcCallOptions)
            }
        }
    }
}
