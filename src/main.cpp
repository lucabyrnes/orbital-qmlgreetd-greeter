#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSettings>
#include <QFile>
#include <QCommandLineParser>
#include "backend/AuthWrapper.h"
#include "backend/SessionModel.h"
#include "backend/UserModel.h"
#include "backend/SystemPower.h"
#include "backend/LayerShell.h"
#include "backend/SystemBattery.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("orbital-greeter");
    app.setApplicationVersion("1.0");

    QCommandLineParser parser;
    parser.setApplicationDescription("Orbital Qt Quick greeter for greetd");
    parser.addHelpOption();
    parser.addVersionOption();

    QCommandLineOption configOption(QStringList() << "c" << "config", "Path to config", "config", "/etc/orbital-greeter/orbital-greeter.conf");
    parser.addOption(configOption);
    parser.process(app);

    // Register QML types
    qmlRegisterType<AuthWrapper>("OrbitalGreeter", 1, 0, "AuthWrapper");
    qmlRegisterType<SessionModel>("OrbitalGreeter", 1, 0, "SessionModel");
    qmlRegisterType<UserModel>("OrbitalGreeter", 1, 0, "UserModel");
    qmlRegisterType<SystemPower>("OrbitalGreeter", 1, 0, "SystemPower");
    qmlRegisterType<LayerShell>("OrbitalGreeter", 1, 0, "LayerShell");
    qmlRegisterType<SystemBattery>("OrbitalGreeter", 1, 0, "SystemBattery");

    // Default Configuration
    QString configPath = parser.value(configOption);
    QString backgroundImagePath;
    QString defaultSession = "";
    QString avatarImagePath = "";
    bool debugBattery = false;
    // Load Configuration
    if (QFile::exists(configPath)) {
        QSettings config(configPath, QSettings::IniFormat);

        config.beginGroup("Appearance");
        backgroundImagePath = config.value("BackgroundImage", "").toString();
        avatarImagePath = config.value("AvatarImage", avatarImagePath).toString();
        config.endGroup();

        config.beginGroup("Debug");
        debugBattery = config.value("debugBattery", debugBattery).toBool();
        config.endGroup();

        config.beginGroup("Behavior");
        config.endGroup();


        config.beginGroup("General");
        defaultSession = config.value("DefaultSession", "").toString();
        config.endGroup();
    }

    // Set background image
    UserModel userModel(avatarImagePath, &app);

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("ConfigBackgroundImage", backgroundImagePath);
    engine.rootContext()->setContextProperty("ConfigDebugBattery", debugBattery);
    engine.rootContext()->setContextProperty("userModel", &userModel);
    engine.rootContext()->setContextProperty("ConfigDefaultSession", defaultSession);

    const QUrl url(QStringLiteral("qrc:/resources/qml/Main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl) QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);

    int result = app.exec();

    return result;
}
