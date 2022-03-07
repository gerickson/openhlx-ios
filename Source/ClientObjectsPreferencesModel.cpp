#import "ClientObjectsPreferencesModel.hpp"

#import <OpenHLX/Utilities/Assert.hpp>


using namespace HLX::Common;


ClientObjectsPreferencesModel :: ClientObjectsPreferencesModel(const ClientObjectsPreferencesModel &aClientObjectsPreferencesModel) :
    mPreferences(aClientObjectsPreferencesModel.mPreferences)
{
    return;
}

Status
ClientObjectsPreferencesModel :: Init(const ClientObjectsPreferencesModel &aClientObjectsPreferencesModel)
{
    Status lRetval = kStatus_Success;


    *this = aClientObjectsPreferencesModel;

    return (lRetval);
}

ClientObjectsPreferencesModel &
ClientObjectsPreferencesModel :: operator =(const ClientObjectsPreferencesModel &aClientObjectsPreferencesModel)
{
    mPreferences = aClientObjectsPreferencesModel.mPreferences;

    return (*this);
}

Status
ClientObjectsPreferencesModel :: GetObjectPreferences(const IdentifierType &aObjectIdentifier, ClientObjectPreferencesModel *&aObjectPreferencesModel)
{
    Status lRetval = kStatus_Success;


    aObjectPreferencesModel = &mPreferences.at(aObjectIdentifier);

 done:
    return (lRetval);
}

Status
ClientObjectsPreferencesModel :: GetObjectPreferences(const IdentifierType &aObjectIdentifier, const ClientObjectPreferencesModel *&aObjectPreferencesModel) const
{
    Status lRetval = kStatus_Success;


    aObjectPreferencesModel = &mPreferences.at(aObjectIdentifier);

 done:
    return (lRetval);
}

Status
ClientObjectsPreferencesModel :: SetObjectPreferences(const IdentifierType &aObjectIdentifier, const ClientObjectPreferencesModel &aObjectPreferencesModel)
{
    Status lRetval = kStatus_Success;


    if (mPreferences[aObjectIdentifier] == aObjectPreferencesModel)
    {
        lRetval = kStatus_ValueAlreadySet;
    }
    else
    {
        mPreferences[aObjectIdentifier] = aObjectPreferencesModel;
    }

 done:
    return (lRetval);
}

bool
ClientObjectsPreferencesModel :: operator ==(const ClientObjectsPreferencesModel &aClientObjectsPreferencesModel) const
{
    return (mPreferences == aClientObjectsPreferencesModel.mPreferences);
}

