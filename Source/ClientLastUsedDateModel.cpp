#import "ClientLastUsedDateModel.hpp"

#import <utility>

#import <errno.h>

#import <CoreFoundation/CFDate.h>

#import <CFUtilities/CFUtilities.hpp>

#import <OpenHLX/Utilities/Assert.hpp>


using namespace HLX;
using namespace HLX::Common;


ClientLastUsedDateModel :: ClientLastUsedDateModel(void) :
    mLastUsedDate(nullptr)
{
    return;
}

ClientLastUsedDateModel :: ~ClientLastUsedDateModel(void)
{
    CFURelease(mLastUsedDate);
}

Status
ClientLastUsedDateModel :: Init(void)
{
    Status lRetval = kStatus_Success;

    CFURelease(mLastUsedDate);

    mLastUsedDate = nullptr;

    return (lRetval);
}

Status
ClientLastUsedDateModel :: Init(const LastUsedDateType &aLastUsedDate)
{
    Status lRetval = kStatus_Success;

    nlREQUIRE_ACTION(aLastUsedDate != nullptr, done, lRetval = -EINVAL);

    CFUReferenceSet(mLastUsedDate, aLastUsedDate);

 done:
    return (lRetval);
}

Status
ClientLastUsedDateModel :: Init(const ClientLastUsedDateModel &aLastUsedDateModel)
{
    Status lRetval = kStatus_Success;
    
    lRetval = Init(aLastUsedDateModel.mLastUsedDate);
    nlREQUIRE(lRetval >= kStatus_Success, done);

done:
    return (lRetval);
}

ClientLastUsedDateModel &
ClientLastUsedDateModel :: operator =(const ClientLastUsedDateModel &aLastUsedDateModel)
{
    Status      lStatus;

    // Avoid a self-copy

    nlEXPECT(&aLastUsedDateModel != this, done);

    if (aLastUsedDateModel.mLastUsedDate != nullptr)
    {
        lStatus = Init(aLastUsedDateModel.mLastUsedDate);
        nlREQUIRE_SUCCESS(lStatus, done);
    }
    else
    {
        CFUReferenceSet(mLastUsedDate, aLastUsedDateModel.mLastUsedDate);
    }

done:
    return (*this);
}

Status
ClientLastUsedDateModel :: GetLastUsedDate(LastUsedDateType &aLastUsedDate) const
{
    Status lRetval = ((mLastUsedDate == nullptr) ? kError_NotInitialized : kStatus_Success);

    if (lRetval == kStatus_Success)
    {
        aLastUsedDate = mLastUsedDate;
    }

    return (lRetval);
}

Status
ClientLastUsedDateModel :: SetLastUsedDate(const LastUsedDateType &aLastUsedDate)
{
    Status lRetval = kStatus_Success;

    // Avoid a self-copy

    nlEXPECT_ACTION(aLastUsedDate != mLastUsedDate, done, lRetval = kStatus_ValueAlreadySet);

    CFUReferenceSet(mLastUsedDate, aLastUsedDate);

done:
    return (lRetval);
}

Status
ClientLastUsedDateModel :: Touch(LastUsedDateType &aOutLastUsedDate)
{
    LastUsedDateType lLastUsedDate = nullptr;
    Status           lRetval       = kStatus_Success;

    lLastUsedDate = CFDateCreate(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent());
    nlREQUIRE_ACTION(lLastUsedDate != nullptr, done, lRetval = -EINVAL);

    lRetval = SetLastUsedDate(lLastUsedDate);
    nlREQUIRE_SUCCESS(lRetval, done);

done:
    return (lRetval);
}

bool
ClientLastUsedDateModel :: operator ==(const ClientLastUsedDateModel &aLastUsedDateModel) const
{
    bool lRetval = false;

    if (this == &aLastUsedDateModel)
    {
        lRetval = true;
    }
    else if ((mLastUsedDate == nullptr) && (aLastUsedDateModel.mLastUsedDate == nullptr))
    {
        lRetval = true;
    }
    else if ((mLastUsedDate != nullptr) && (aLastUsedDateModel.mLastUsedDate != nullptr))
    {
        lRetval = CFEqual(mLastUsedDate, aLastUsedDateModel.mLastUsedDate);
    }

    return (lRetval);
}
