
#ifndef OPENHLXCLIENTMODELLASTUSEDDATEMODEL_HPP
#define OPENHLXCLIENTMODELLASTUSEDDATEMODEL_HPP


#include <CoreFoundation/CFDate.h>

#include <OpenHLX/Common/Errors.hpp>


class ClientLastUsedDateModel
{
public:
    typedef CFDateRef LastUsedDateType;

public:
    ClientLastUsedDateModel(void);
    virtual ~ClientLastUsedDateModel(void);

    HLX::Common::Status Init(void);
    HLX::Common::Status Init(const LastUsedDateType &aLastUsedDate);
    HLX::Common::Status Init(const ClientLastUsedDateModel &aLastUsedDateModel);

    ClientLastUsedDateModel &operator =(const ClientLastUsedDateModel &aLastUsedDateModel);

    HLX::Common::Status GetLastUsedDate(LastUsedDateType &aLastUsedDate) const;

    HLX::Common::Status SetLastUsedDate(const LastUsedDateType &aLastUsedDate);
    HLX::Common::Status Touch(LastUsedDateType &aOutLastUsedDate);

    bool operator ==(const ClientLastUsedDateModel &aLastUsedDateModel) const;

private:
    LastUsedDateType  mLastUsedDate;
};

#endif // OPENHLXCLIENTMODELLASTUSEDDATEMODEL_HPP
