#import "ClientObjectsPreferencesModel.hpp"

#import <errno.h>

#import <LogUtilities/LogUtilities.hpp>

#import <OpenHLX/Utilities/Assert.hpp>


using namespace HLX;
using namespace HLX::Common;
using namespace HLX::Model;
using namespace Nuovations;
using namespace std;


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
ClientObjectsPreferencesModel :: GetObjectIdentifiers(IdentifiersCollection &aObjectIdentifiers) const
{
    ObjectsPreferences::const_iterator lIterator = mPreferences.begin();
    Status lRetval = kStatus_Success;

    lRetval = aObjectIdentifiers.ClearIdentifiers();
    nlREQUIRE_SUCCESS(lRetval, done);

    while (lIterator != mPreferences.end())
    {
        lRetval = aObjectIdentifiers.AddIdentifier(lIterator->first);
        nlREQUIRE_SUCCESS(lRetval, done);

        lIterator++;
    }

 done:
    return (lRetval);
}

Status
ClientObjectsPreferencesModel :: GetObjectPreferences(const IdentifierType &aObjectIdentifier, ClientObjectPreferencesModel *&aObjectPreferencesModel)
{
    ObjectsPreferences::iterator lIterator = mPreferences.find(aObjectIdentifier);
    Status                       lRetval   = kStatus_Success;


    // There may be no preferences at all for this object. Consequently,
    // it is expected that there will be no valid iterator.

    nlEXPECT_ACTION(lIterator != mPreferences.end(), done, lRetval = -ENOENT);

    aObjectPreferencesModel = &lIterator->second;

 done:
    return (lRetval);
}

Status
ClientObjectsPreferencesModel :: GetObjectPreferences(const IdentifierType &aObjectIdentifier, const ClientObjectPreferencesModel *&aObjectPreferencesModel) const
{
    ObjectsPreferences::const_iterator lIterator = mPreferences.find(aObjectIdentifier);
    Status                             lRetval   = kStatus_Success;


    // There may be no preferences at all for this object. Consequently,
    // it is expected that there will be no valid iterator.

    nlEXPECT_ACTION(lIterator != mPreferences.end(), done, lRetval = -ENOENT);

    aObjectPreferencesModel = &lIterator->second;

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

