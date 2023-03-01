module Evergreen.Migrate.V2 exposing (..)

import Evergreen.V1.Record as Old
import Evergreen.V1.Types as Old
import Evergreen.V2.Duration as New
import Evergreen.V2.Record as New
import Evergreen.V2.Types as New
import Lamdera.Migrations exposing (..)


frontendModel : Old.FrontendModel -> ModelMigration New.FrontendModel New.FrontendMsg
frontendModel old =
    ModelMigrated
        ( { key = old.key
          , players = old.players
          , selectedPlayers = old.selectedPlayers
          , timeString = old.timeString
          , records = New.Loading
          }
        , Cmd.none
        )


oldToNewRecord : Old.Record -> New.Record
oldToNewRecord old =
    { id = old.id
    , duration = fromFloat old.time
    , date = old.date
    , players = old.players
    }


fromFloat : Float -> New.Duration
fromFloat float =
    let
        n =
            truncate (float * 100)

        minutes =
            n // 100

        seconds =
            modBy 100 n
    in
    New.Duration <| minutes * 60 + seconds


backendModel : Old.BackendModel -> ModelMigration New.BackendModel New.BackendMsg
backendModel old =
    ModelMigrated
        ( { records = List.map oldToNewRecord old.records
          , nextId = old.nextId
          }
        , Cmd.none
        )


frontendMsg : Old.FrontendMsg -> MsgMigration New.FrontendMsg New.FrontendMsg
frontendMsg old =
    case old of
        Old.UrlClicked _ ->
            MsgUnchanged

        Old.UrlChanged _ ->
            MsgUnchanged

        Old.NoOpFrontendMsg ->
            MsgUnchanged

        Old.DidCheckPlayer _ _ ->
            MsgUnchanged

        Old.DidInputTime _ ->
            MsgUnchanged

        Old.ClickedAddRecord ->
            MsgUnchanged

        Old.GotNow float posix ->
            MsgMigrated ( New.GotNow (fromFloat float) posix, Cmd.none )

        Old.ClickedDelete _ ->
            MsgUnchanged


toBackend : Old.ToBackend -> MsgMigration New.ToBackend New.BackendMsg
toBackend old =
    case old of
        Old.CreateNewRecord float posix setOfStrings ->
            MsgMigrated ( New.CreateNewRecord (fromFloat float) posix setOfStrings, Cmd.none )

        Old.GetRecords ->
            MsgUnchanged

        Old.DeleteRecord _ ->
            MsgUnchanged


backendMsg : Old.BackendMsg -> MsgMigration New.BackendMsg New.BackendMsg
backendMsg _ =
    MsgUnchanged


toFrontend : Old.ToFrontend -> MsgMigration New.ToFrontend New.FrontendMsg
toFrontend old =
    case old of
        Old.NoOpToFrontend ->
            MsgUnchanged

        Old.UpdateRecords records ->
            MsgMigrated ( New.UpdateRecords (List.map oldToNewRecord records), Cmd.none )
