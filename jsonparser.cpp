#include "jsonparser.h"
#include <QJsonObject>
#include <QJsonDocument>
#include <QVariant>
#include <QFile>
#include <QJsonArray>
#include <QDebug>
#include <QString>


JsonParser::JsonParser()
{
    QString val;
    QFile file;
    file.setFileName("code_model.json");
    file.open(QIODevice::ReadOnly | QIODevice::Text);
    val = file.readAll();
    file.close();

    QJsonParseError error;
    QJsonDocument fullData = QJsonDocument::fromJson(val.toUtf8(), &error);
    QJsonObject fullObject = fullData.object();

    QJsonValue listClasses = fullObject.value(QString("listClasses"));
    QJsonObject listClassesObject = listClasses.toObject();
    QJsonValue listLinks = fullObject.value(QString("listLinks"));
    QJsonObject listLinksObject = listLinks.toObject();

    QJsonValue classes = listClassesObject.value(QString("classes"));
    _classesArray = classes.toArray();

    QJsonValue links = listLinksObject.value(QString("links"));
    _linksArray = links.toArray();


}

QJsonArray JsonParser::listClasses()
{
    QJsonArray result;
    foreach (const QJsonValue & value, _classesArray) {
        QJsonObject obj = value.toObject();
        result.append(obj["name"].toString());
    }
}

QJsonArray JsonParser::listClassAttributes(QString classRequested)
{
    QJsonArray result;
    foreach (const QJsonValue & value, _classesArray) {
        QJsonObject obj = value.toObject();
        if (obj["name"].toString() == classRequested)
        {
            result = obj["attributes"].toArray();
        }
    }
}

JsonParser::~JsonParser()
{

}

