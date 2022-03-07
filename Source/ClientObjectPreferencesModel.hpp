#ifndef OPENHLXCLIENTMODELOBJECTPREFERENCESMODEL_HPP
#define OPENHLXCLIENTMODELOBJECTPREFERENCESMODEL_HPP


#import "ClientFavoriteModel.hpp"
#import "ClientLastUsedDateModel.hpp"


class ClientObjectPreferencesModel
{
public:
    typedef ClientFavoriteModel::FavoriteType         FavoriteType;
    typedef ClientLastUsedDateModel::LastUsedDateType LastUsedDateType;

public:
    ClientObjectPreferencesModel(void) = default;
    ~ClientObjectPreferencesModel(void) = default;

    HLX::Common::Status Init(void);
    HLX::Common::Status Init(const ClientObjectPreferencesModel &aClientObjectPreferencesModel);

    ClientObjectPreferencesModel &operator =(const ClientObjectPreferencesModel &aClientObjectPreferencesModel);

    HLX::Common::Status GetFavorite(FavoriteType &aFavorite) const;
    HLX::Common::Status GetLastUsedDate(LastUsedDateType &aLastUsedDate) const;

    HLX::Common::Status SetFavorite(const FavoriteType &aFavorite);
    HLX::Common::Status SetLastUsedDate(const LastUsedDateType &aLastUsedDate);

    bool operator ==(const ClientObjectPreferencesModel &aClientObjectPreferencesModel) const;

private:
    ClientFavoriteModel     mFavorite;
    ClientLastUsedDateModel mLastUsedDate;

};

#endif // OPENHLXCLIENTMODELOBJECTPREFERENCESMODEL_HPP
