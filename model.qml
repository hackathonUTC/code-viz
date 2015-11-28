import QtQuick 2.0

Item {

    /*
      class :
        - name
    */
    ListModel {
        id: listClasses;


    }

    /*
      method :
        - name
        - isPublic (private / public)
    */
    ListModel {
        id: listMethods;
    }

    /*
      attribute :
        - name
    */
    ListModel {
        id: listAttributes;

    }

    /*
      link :
        - type (ownsAttribute, ownsMethod, inherits, overloads, calls)
        - from
        - to

        ownsAttribue : from class to attribute
        ownsMethod : from class to method
        inherits : from class to class
        overloads : from method to method
        calls : from method to method
    */
    ListModel {
        id: listLinks;


    }
}

