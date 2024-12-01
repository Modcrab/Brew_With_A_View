// Author: Modcrab

@wrapMethod(CPlayer)
function SetIsHorseMounted( isOn : bool )
{
    if (isOn)
    {
        BlockAction(EIAB_OpenMeditation, 'modAlchemyRequiresMeditationMounted');
    }
    else
    {
        UnblockAction(EIAB_OpenMeditation, 'modAlchemyRequiresMeditationMounted');
    }
    wrappedMethod(isOn);
}