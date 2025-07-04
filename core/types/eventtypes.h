#pragma once
#include <QString>

namespace EventTypes {

    namespace Global {
        static const QString SetVisibility = QStringLiteral("Global.SetVisibility");
    }

    namespace TrackLayer {
        static const QString ToggleVisibility = QStringLiteral("TrackLayer.ToggleVisibility");
        static const QString GetVisibility    = QStringLiteral("TrackLayer.GetVisibility");
        static const QString UpdateTrack      = QStringLiteral("TrackLayer.UpdateTrack");
        static const QString DeleteTrack      = QStringLiteral("TrackLayer.DeleteTrack");
    }

    namespace StaticPoi {
        static const QString AddPoi    = QStringLiteral("StaticPoi.AddPoi");
        static const QString RemovePoi = QStringLiteral("StaticPoi.RemovePoi");
    }

    namespace Map {
        static const QString Zoom     = QStringLiteral("Map.Zoom");
        static const QString Visible  = QStringLiteral("Map.Visibility");
        static const QString Active   = QStringLiteral("Map.Active");
        static const QString SelectionBox = QStringLiteral("Map.SelectionBox");
    }
}
