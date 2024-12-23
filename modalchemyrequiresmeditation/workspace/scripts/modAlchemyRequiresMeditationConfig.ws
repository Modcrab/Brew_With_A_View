// Author: Modcrab

function ModcrabAlchemyRequiresMeditationGetConfigValueAsString( valueID : name ) : string
{
	var configWrapper: CInGameConfigWrapper;
	var valueAsString: string;
	configWrapper = theGame.GetInGameConfigWrapper();
	valueAsString = configWrapper.GetVarValue('modAlchemyRequiresMeditation', valueID);
	return valueAsString;
}

function ModcrabAlchemyRequiresMeditationGetConfigValueAsBool( valueID : name ) : bool
{
	return (bool)ModcrabAlchemyRequiresMeditationGetConfigValueAsString( valueID );
}

function ModcrabAlchemyRequiresMeditationGetConfigValueAsFloat( valueID : name ) : float
{
	return StringToFloat( ModcrabAlchemyRequiresMeditationGetConfigValueAsString( valueID ) );
}

function ModcrabAlchemyRequiresMeditationGetConfigValueAsEModcrabMeditationCameraStyle( valueID : name ) : EModcrabMeditationCameraStyle
{
	var intValue : int;
	intValue = StringToInt( ModcrabAlchemyRequiresMeditationGetConfigValueAsString( valueID ) );
	return (EModcrabMeditationCameraStyle)intValue;
}