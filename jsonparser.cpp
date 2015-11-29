#include "jsonparser.h"
#include <QJsonObject>
#include <QJsonDocument>
#include <QVariant>
#include <QFile>
#include <QJsonArray>
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
    return result;
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
    return result;
}

QJsonArray JsonParser::listClassMethods(QString classRequested)
{
    QJsonArray result;
    foreach (const QJsonValue & value, _classesArray) {
        QJsonObject obj = value.toObject();
        if (obj["name"].toString() == classRequested)
        {
            result = obj["methods"].toArray();
        }
    }
    return result;
}

QJsonArray JsonParser::listLinksCallsInside(QString classRequested)
{
    QJsonArray result;
    foreach (const QJsonValue & value, _linksArray) {
        QJsonObject obj = value.toObject();

        if (obj["type"].toString() == "calls"
                && obj["classFrom"].toString() == classRequested
                && obj["classFrom"].toString() == obj["classTo"].toString())
        {
            result.append(obj);
        }
    }
    return result;
}

QJsonArray JsonParser::listLinksCallsOutside(QString classRequested)
{
    QJsonArray result;
    foreach (const QJsonValue & value, _linksArray) {
        QJsonObject obj = value.toObject();

        if (obj["type"].toString() == "calls"
                && obj["classFrom"].toString() == classRequested
                && obj["classFrom"].toString() != obj["classTo"].toString())
        {
            result.append(obj);
        }
    }
    return result;
}

QJsonArray JsonParser::listLinksReferences(QString classRequested, QString methodName)
{
    QJsonArray result;
    foreach (const QJsonValue & value, _linksArray) {
        QJsonObject obj = value.toObject();

        if (obj["type"].toString() == "references"
                && obj["class"].toString() == classRequested
                && obj["method"].toString() == methodName)
        {
            result.append(obj);
        }
    }
    return result;
}

QJsonArray JsonParser::listLinksInherits(QString classRequested)
{
    QJsonArray result;
    foreach (const QJsonValue & value, _linksArray) {
        QJsonObject obj = value.toObject();

        if (obj["type"].toString() == "inherits"
                && obj["classFrom"].toString() == classRequested)
        {
            result.append(obj);
        }
    }
    return result;
}

QJsonArray JsonParser::listLinksInheritsReverse(QString classRequested)
{
    QJsonArray result;
    foreach (const QJsonValue & value, _linksArray) {
        QJsonObject obj = value.toObject();

        if (obj["type"].toString() == "inherits"
                && obj["classTo"].toString() == classRequested)
        {
            result.append(obj);
        }
    }
    return result;
}

JsonParser::~JsonParser()
{

}

/**

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Fusce augue ligula, viverra a elit venenatis, tempus fringilla lorem. Mauris enim erat, maximus sed nulla sit amet, vehicula dignissim leo. Aliquam dignissim, mauris vitae consequat ultrices, dui elit maximus nisi, at consectetur orci nisl a orci. Quisque iaculis tortor orci, non cursus augue commodo et. In eleifend orci arcu, nec mattis justo placerat sit amet. Nulla facilisi. Nullam consequat sem massa, vel laoreet nisl gravida non. Quisque egestas nisi sit amet dolor ullamcorper viverra. In urna lectus, placerat et sem a, fringilla imperdiet nibh. Donec in ornare neque.

Vivamus sed mi quis leo egestas gravida. Praesent porta dui a est consequat pellentesque. Fusce facilisis eleifend urna in bibendum. Phasellus sodales sem eu nisi bibendum consectetur. Aenean arcu nibh, egestas vitae libero vitae, laoreet imperdiet nulla. Pellentesque rhoncus ornare dolor ut tristique. Proin fringilla nibh a leo sagittis lacinia in ut felis.
Coucou.
Proin mollis dapibus tristique. Curabitur quam mi, porttitor quis sagittis a, pulvinar ut orci. Fusce ultricies eleifend purus quis ultrices. Vivamus eleifend euismod est, eget lacinia velit. Nulla nec molestie est. Maecenas sed tristique eros. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Nam congue vestibulum mauris in ullamcorper.
Tu veux voir mon git ?
Etiam et aliquam diam, nec porttitor lectus. Praesent fringilla, velit quis commodo cursus, ipsum purus facilisis tortor, a interdum metus nibh vitae est. Donec sem magna, pharetra non luctus ac, dignissim quis metus. Etiam ac odio in augue viverra faucibus eget in diam. Nunc eu augue non lacus sollicitudin tempus id ac justo. Fusce elementum metus id quam commodo, eu dictum enim viverra. Nunc sed elit ut libero gravida gravida eu a felis. Nullam semper efficitur turpis sit amet elementum. Nulla eros metus, pharetra a commodo et, pulvinar non arcu. Mauris egestas eget tortor a mattis.

Proin bibendum arcu non ullamcorper tempor. Aenean ex metus, luctus a magna vel, lacinia ullamcorper tortor. Integer ac facilisis sapien, a porta eros. Etiam tristique sollicitudin purus quis ornare. Donec purus tortor, tincidunt at nisl nec, consequat auctor tortor. Nulla consectetur metus quis eros porttitor, eu laoreet mauris tincidunt. Nam ac velit vitae justo iaculis consequat eget dapibus urna. Fusce molestie tempor metus nec ornare. Nullam sagittis, quam eget ornare dignissim, nunc felis viverra justo, suscipit mollis mauris leo nec elit. Proin viverra diam id augue pretium condimentum. In venenatis interdum blandit. Vivamus sit amet dui commodo, elementum dui nec, fringilla diam. Vestibulum diam purus, eleifend sit amet lacus at, imperdiet suscipit tortor.
*/
