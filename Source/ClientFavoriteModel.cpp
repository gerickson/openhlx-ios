#include "ClientFavoriteModel.hpp"

#include <OpenHLX/Common/Errors.hpp>
#include <OpenHLX/Utilities/Assert.hpp>


using namespace HLX::Common;


ClientFavoriteModel :: ClientFavoriteModel(void) :
    mFavoriteIsNull(true),
    mFavorite(false)
{
    return;
}

Status
ClientFavoriteModel :: Init(void)
{
    Status lRetval = kStatus_Success;

    mFavorite        = false;
    mFavoriteIsNull  = true;

    return (lRetval);
}

Status
ClientFavoriteModel :: Init(const FavoriteType &aFavorite)
{
    Status lRetval = kStatus_Success;

    lRetval = SetFavorite(aFavorite);
    nlREQUIRE(lRetval >= kStatus_Success, done);

 done:
    if (lRetval == kStatus_ValueAlreadySet)
    {
        lRetval = kStatus_Success;
    }

    return (lRetval);

}

Status
ClientFavoriteModel :: Init(const ClientFavoriteModel &aFavoriteModel)
{
    Status lRetval = kStatus_Success;

    *this = aFavoriteModel;

    return (lRetval);
}

ClientFavoriteModel &
ClientFavoriteModel :: operator =(const ClientFavoriteModel &aFavoriteModel)
{
    mFavoriteIsNull = aFavoriteModel.mFavoriteIsNull;
    mFavorite       = aFavoriteModel.mFavorite;

    return (*this);
}

Status
ClientFavoriteModel :: GetFavorite(FavoriteType &aFavorite) const
{
    Status lRetval = ((mFavoriteIsNull) ? kError_NotInitialized : kStatus_Success);

    if (lRetval == kStatus_Success)
    {
        aFavorite = mFavorite;
    }

    return (lRetval);
}

Status ClientFavoriteModel :: SetFavorite(const FavoriteType &aFavorite)
{
    Status lRetval = kStatus_Success;

    if (mFavorite == aFavorite)
    {
        lRetval = ((mFavoriteIsNull) ? kStatus_Success : kStatus_ValueAlreadySet);
    }
    else
    {
        mFavorite = aFavorite;
    }

    mFavoriteIsNull = false;

    return (lRetval);
}

Status
ClientFavoriteModel :: ToggleFavorite(FavoriteType &aOutFavorite)
{
    Status lRetval = kStatus_Success;

    nlREQUIRE_ACTION(!mFavoriteIsNull, done, lRetval = kError_NotInitialized);

    mFavorite = !mFavorite;

    aOutFavorite = mFavorite;

 done:
    return (lRetval);
}

bool
ClientFavoriteModel :: operator ==(const ClientFavoriteModel &aFavoriteModel) const
{
    return ((mFavoriteIsNull  == aFavoriteModel.mFavoriteIsNull) &&
            (mFavorite        == aFavoriteModel.mFavorite      ));
}
