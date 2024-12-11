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