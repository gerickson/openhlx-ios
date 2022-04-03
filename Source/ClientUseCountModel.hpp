
#ifndef OPENHLXIOSCLIENTUSECOUNTMODEL_HPP
#define OPENHLXIOSCLIENTUSECOUNTMODEL_HPP


#include <stdint.h>

#include <OpenHLX/Common/Errors.hpp>


class ClientUseCountModel
{
public:
    typedef uint32_t UseCountType;

public:
    ClientUseCountModel(void);
    virtual ~ClientUseCountModel(void);

    HLX::Common::Status Init(void);
    HLX::Common::Status Init(const UseCountType &aUseCount);
    HLX::Common::Status Init(const ClientUseCountModel &aUseCountModel);

    ClientUseCountModel &operator =(const ClientUseCountModel &aUseCountModel);

    HLX::Common::Status GetUseCount(UseCountType &aUseCount) const;

    HLX::Common::Status SetUseCount(const UseCountType &aUseCount);
    HLX::Common::Status IncrementUseCount(UseCountType &aOutUseCount);
    HLX::Common::Status Touch(UseCountType &aOutUseCount);
    HLX::Common::Status ResetUseCount(UseCountType &aOutUseCount);

    bool operator ==(const ClientUseCountModel &aUseCountModel) const;

private:
    UseCountType  mUseCount;
};

#endif // OPENHLXIOSCLIENTUSECOUNTMODEL_HPP
