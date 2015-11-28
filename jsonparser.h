#ifndef JSONPARSER_H
#define JSONPARSER_H

#include <QJsonArray>
#include <QString>


class JsonParser
{
private:
    QJsonArray _classesArray;
    QJsonArray _linksArray;


public:
    JsonParser();
    ~JsonParser();
    QJsonArray listClasses();
    QJsonArray listClassAttributes(QString classRequested);
};

#endif // JSONPARSER_H
