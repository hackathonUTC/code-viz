TEMPLATE = app

QT += qml quick
CONFIG += c++11

SOURCES += main.cpp \
    jsonparser.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)
<<<<<<< HEAD

HEADERS += \
    jsonparser.h

=======
>>>>>>> 358242089eef9a0fd25f3c73c8d1d12200ddfcfb
