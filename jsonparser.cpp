#include "jsonparser.h"
#include <QJsonObject>
#include <QJsonDocument>
#include <QVariant>
#include <QFile>
#include <QJsonArray>
#include <QDebug>

/*
{
   "appDesc": {
      "description": "SomeDescription",
      "message": "SomeMessage"
   },
   "appName": {
      "description": "Home",
      "message": "Welcome",
      "imp":["awesome","best","good"]
   }
}
*/
/*
 QJsonDocument d = QJsonDocument::fromJson(val.toUtf8());
      QJsonObject sett2 = d.object();
      QJsonValue value = sett2.value(QString("appName"));
      QJsonObject item = value.toObject();

      QJsonValue subobj = item["description"];

      QJsonArray test = item["imp"].toArray();
*/

JsonParser::JsonParser()
{
    QString val;
    QFile file;
    file.setFileName("code_model.json");
    file.open(QIODevice::ReadOnly);
    val = file.readAll();
    qDebug() << val;
    file.close();

    QJsonDocument d = QJsonDocument::fromJson(val.toUtf8());
    QJsonObject sett2 = d.object();

    QJsonValue fullData = sett2.value(QString("data"));
    QJsonObject fullObject = fullData.toObject();

    QJsonValue listClasses = fullObject.value(QString("listClasses"));
    QJsonObject listClassesObject = listClasses.toObject();
    QJsonValue listLinks = fullObject.value(QString("listLinks"));
    QJsonObject listLinksObject = listLinks.toObject();



    QJsonValue classes = listClassesObject.value(QString("classes"));
    QJsonArray classesArray = classes.toArray();




    QJsonValue links = listLinksObject.value(QString("links"));



}

JsonParser::~JsonParser()
{

}

