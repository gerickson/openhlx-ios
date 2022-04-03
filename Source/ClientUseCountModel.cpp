#import "ClientUseCountModel.hpp"

#import <utility>

#import <errno.h>

#import <CoreFoundation/CFDate.h>

#import <CFUtilities/CFUtilities.hpp>

#import <OpenHLX/Utilities/Assert.hpp>


using namespace HLX;
using namespace HLX::Common;


ClientUseCountModel :: ClientUseCountModel(void) :
    mUseCount(0)
{
    return;
}

ClientUseCountModel :: ~ClientUseCountModel(void)
{
    return;
}

Status
ClientUseCountModel :: Init(void)
{
    Status lRetval = kStatus_Success;

    mUseCount = 0;

    return (lRetval);
}

Status
ClientUseCountModel :: Init(const UseCountType &aUseCount)
{
    Status lRetval = kStatus_Success;

    mUseCount = aUseCount;

 done:
    return (lRetval);
}

Status
ClientUseCountModel :: Init(const ClientUseCountModel &aUseCountModel)
{
    Status lRetval = kStatus_Success;
    
    lRetval = Init(aUseCountModel.mUseCount);
    nlREQUIRE(lRetval >= kStatus_Success, done);

done:
    return (lRetval);
}

ClientUseCountModel &
ClientUseCountModel :: operator =(const ClientUseCountModel &aUseCountModel)
{
    // Avoid a self-copy

    nlEXPECT(&aUseCountModel != this, done);

    mUseCount = aUseCountModel.mUseCount;

done:
    return (*this);
}

Status
ClientUseCountModel :: GetUseCount(UseCountType &aUseCount) const
{
    Status lRetval = kStatus_Success;

    aUseCount = mUseCount;

    return (lRetval);
}

Status
ClientUseCountModel :: SetUseCount(const UseCountType &aUseCount)
{
    Status lRetval = kStatus_Success;

    // Avoid a self-copy

    nlEXPECT_ACTION(aUseCount != mUseCount, done, lRetval = kStatus_ValueAlreadySet);

    mUseCount = aUseCount;

done:
    return (lRetval);
}

Status
ClientUseCountModel :: IncrementUseCount(UseCountType &aOutUseCount)
{
    const UseCountType  lUseCount = mUseCount + 1;
    Status              lRetval   = kStatus_Success;

    lRetval = SetUseCount(lUseCount);
    nlREQUIRE_SUCCESS(lRetval, done);

    aOutUseCount = lUseCount;

done:
    return (lRetval);
}

Status
ClientUseCountModel :: Touch(UseCountType &aOutUseCount)
{
    const Status lRetval = IncrementUseCount(aOutUseCount);

    return (lRetval);
}

Status
ClientUseCountModel :: ResetUseCount(UseCountType &aOutUseCount)
{
    const UseCountType  lUseCount = 0;
    Status              lRetval   = kStatus_Success;

    lRetval = SetUseCount(lUseCount);
    nlREQUIRE(lRetval >= kStatus_Success, done);

    aOutUseCount = lUseCount;

done:
    return (lRetval);
}

bool
ClientUseCountModel :: operator ==(const ClientUseCountModel &aUseCountModel) const
{
    bool lRetval = false;

    if (this == &aUseCountModel)
    {
        lRetval = true;
    }
    else
    {
        lRetval = (mUseCount == aUseCountModel.mUseCount);
    }

    return (lRetval);
}
