#import "ClientObjectPreferencesModel.hpp"

#import <LogUtilities/LogUtilities.hpp>

#import <OpenHLX/Utilities/Assert.hpp>


using namespace HLX;
using namespace HLX::Common;
using namespace Nuovations;


Status
ClientObjectPreferencesModel :: Init(void)
{
    Status lRetval = kStatus_Success;

    lRetval = mFavorite.Init();
    nlREQUIRE(lRetval >= kStatus_Success, done);

    lRetval = mLastUsedDate.Init();
    nlREQUIRE(lRetval >= kStatus_Success, done);

    lRetval = mUseCount.Init();
    nlREQUIRE(lRetval >= kStatus_Success, done);

done:
    if (lRetval == kStatus_ValueAlreadySet)
    {
        lRetval = kStatus_Success;
    }

    return (lRetval);
}

Status
ClientObjectPreferencesModel :: Init(const ClientObjectPreferencesModel &aClientObjectPreferencesModel)
{
    Status lRetval = kStatus_Success;

    lRetval = mFavorite.Init(aClientObjectPreferencesModel.mFavorite);
    nlREQUIRE(lRetval >= kStatus_Success, done);

    lRetval = mLastUsedDate.Init(aClientObjectPreferencesModel.mLastUsedDate);
    nlREQUIRE(lRetval >= kStatus_Success, done);

    lRetval = mUseCount.Init(aClientObjectPreferencesModel.mUseCount);
    nlREQUIRE(lRetval >= kStatus_Success, done);

 done:
    if (lRetval == kStatus_ValueAlreadySet)
    {
        lRetval = kStatus_Success;
    }

    return (lRetval);
}

ClientObjectPreferencesModel &
ClientObjectPreferencesModel :: operator =(const ClientObjectPreferencesModel &aClientObjectPreferencesModel)
{
    mFavorite      = aClientObjectPreferencesModel.mFavorite;
    mLastUsedDate  = aClientObjectPreferencesModel.mLastUsedDate;
    mUseCount      = aClientObjectPreferencesModel.mUseCount;

    return (*this);
}

Status
ClientObjectPreferencesModel :: GetFavorite(FavoriteType &aFavorite) const
{
    Status lRetval = kStatus_Success;

    lRetval = mFavorite.GetFavorite(aFavorite);
    nlREQUIRE_SUCCESS(lRetval, done);

 done:
    return (lRetval);
}

Status
ClientObjectPreferencesModel :: GetLastUsedDate(LastUsedDateType &aLastUsedDate) const
{
    Status lRetval = kStatus_Success;

    lRetval = mLastUsedDate.GetLastUsedDate(aLastUsedDate);
    nlREQUIRE_SUCCESS(lRetval, done);

 done:
    return (lRetval);
}

Status
ClientObjectPreferencesModel :: GetUseCount(UseCountType &aUseCount) const
{
    Status lRetval = kStatus_Success;

    lRetval = mUseCount.GetUseCount(aUseCount);
    nlREQUIRE_SUCCESS(lRetval, done);

 done:
    return (lRetval);
}

Status
ClientObjectPreferencesModel :: SetFavorite(const FavoriteType &aFavorite)
{
    Status lRetval = kStatus_Success;

    lRetval = mFavorite.SetFavorite(aFavorite);
    nlREQUIRE(lRetval >= kStatus_Success, done);

 done:
    return (lRetval);
}

Status
ClientObjectPreferencesModel :: SetLastUsedDate(const LastUsedDateType &aLastUsedDate)
{
    Status lRetval = kStatus_Success;

    lRetval = mLastUsedDate.SetLastUsedDate(aLastUsedDate);
    nlREQUIRE(lRetval >= kStatus_Success, done);

 done:
    return (lRetval);
}

Status
ClientObjectPreferencesModel :: SetUseCount(const UseCountType &aUseCount)
{
    Status lRetval = kStatus_Success;

    lRetval = mUseCount.SetUseCount(aUseCount);
    nlREQUIRE(lRetval >= kStatus_Success, done);

 done:
    return (lRetval);
}

Status
ClientObjectPreferencesModel :: IncrementUseCount(UseCountType &aUseCount)
{
    Status lRetval = kStatus_Success;

    lRetval = mUseCount.IncrementUseCount(aUseCount);
    nlREQUIRE(lRetval >= kStatus_Success, done);

 done:
    return (lRetval);
}

bool
ClientObjectPreferencesModel :: operator ==(const ClientObjectPreferencesModel &aClientObjectPreferencesModel) const
{
    return ((mFavorite     == aClientObjectPreferencesModel.mFavorite    ) &&
            (mLastUsedDate == aClientObjectPreferencesModel.mLastUsedDate) &&
            (mUseCount     == aClientObjectPreferencesModel.mUseCount    ));
}
