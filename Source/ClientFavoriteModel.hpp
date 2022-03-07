#ifndef OPENHLXCLIENTMODELFAVORITEMODEL_HPP
#define OPENHLXCLIENTMODELFAVORITEMODEL_HPP


#import <OpenHLX/Common/Errors.hpp>


class ClientFavoriteModel
{
public:
    typedef bool FavoriteType;

public:
    ClientFavoriteModel(void);
    virtual ~ClientFavoriteModel(void) = default;

    HLX::Common::Status Init(void);
    HLX::Common::Status Init(const FavoriteType &aFavorite);
    HLX::Common::Status Init(const ClientFavoriteModel &aFavoriteModel);

    ClientFavoriteModel &operator =(const ClientFavoriteModel &aFavoriteModel);

    HLX::Common::Status GetFavorite(FavoriteType &aFavorite) const;

    HLX::Common::Status SetFavorite(const FavoriteType &aFavorite);
    HLX::Common::Status ToggleFavorite(FavoriteType &aOutFavorite);

    bool operator ==(const ClientFavoriteModel &aFavoriteModel) const;

private:
    bool          mFavoriteIsNull;
    FavoriteType  mFavorite;
};

#endif // OPENHLXCLIENTMODELFAVORITEMODEL_HPP
