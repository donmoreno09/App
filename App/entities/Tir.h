#ifndef TIR_H
#define TIR_H

#include <QString>
#include "BaseTrack.h"

class Tir : public BaseTrack
{
public:
    QString operationCode; // operationCode:  string
    double vel;            // vel:            number
};

#endif // TIR_H
