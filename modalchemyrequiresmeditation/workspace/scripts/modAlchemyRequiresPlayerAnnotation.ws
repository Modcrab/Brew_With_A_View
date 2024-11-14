// Author: Modcrab

@wrapMethod(CPlayer)
function SetIsHorseMounted( isOn : bool )
{
    if (isOn)
    {
        BlockAction(EIAB_OpenMeditation, 'modAlchemyRequiresMeditation');
    }
    else
    {
        UnblockAction(EIAB_OpenMeditation, 'modAlchemyRequiresMeditation');
    }
    wrappedMethod(isOn);
}