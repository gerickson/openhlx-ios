#ifndef OPENHLXCLIENTMODELOBJECTSPREFERENCESMODEL_HPP
#define OPENHLXCLIENTMODELOBJECTSPREFERENCESMODEL_HPP


#import <map>

#import <OpenHLX/Common/Errors.hpp>
#import <OpenHLX/Model/IdentifiersCollection.hpp>
#import <OpenHLX/Model/IdentifierModel.hpp>

#import "ClientObjectPreferencesModel.hpp"


class ClientObjectsPreferencesModel
{
public:
    typedef HLX::Model::IdentifierModel::IdentifierType IdentifierType;

public:
    ClientObjectsPreferencesModel(void) = default;
    ClientObjectsPreferencesModel(const ClientObjectsPreferencesModel &aClientObjectsPreferencesModel);
    ~ClientObjectsPreferencesModel(void) = default;
    
    HLX::Common::Status Init(const ClientObjectsPreferencesModel &aClientObjectsPreferencesModel);

    ClientObjectsPreferencesModel &operator =(const ClientObjectsPreferencesModel &aClientObjectsPreferencesModel);

    HLX::Common::Status GetObjectIdentifiers(HLX::Model::IdentifiersCollection &aObjectIdentifiers) const;

    HLX::Common::Status GetObjectPreferences(const IdentifierType &aObjectIdentifier, ClientObjectPreferencesModel *&aObjectPreferencesModel);
    HLX::Common::Status GetObjectPreferences(const IdentifierType &aObjectIdentifier, const ClientObjectPreferencesModel *&aObjectPreferencesModel) const;

    HLX::Common::Status SetObjectPreferences(const IdentifierType &aObjectIdentifier, const ClientObjectPreferencesModel &aObjectPreferencesModel);

    bool operator ==(const ClientObjectsPreferencesModel &aClientObjectsPreferencesModel) const;

private:
    typedef std::map<HLX::Model::IdentifierModel::IdentifierType, ClientObjectPreferencesModel> ObjectsPreferences;

    ObjectsPreferences mPreferences;
};

#endif // OPENHLXCLIENTMODELOBJECTSPREFERENCESMODEL_HPP
