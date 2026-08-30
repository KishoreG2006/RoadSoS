// ignore_for_file: constant_identifier_names, experimental_member_use
// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'user_model.dart';

Id _userModelGetId(UserModel object) => object.isarId;
List<IsarLinkBase<dynamic>> _userModelGetLinks(UserModel object) => [];
void _userModelAttach(IsarCollection<dynamic> col, Id id, UserModel object) {
  object.isarId = id;
}

const UserModelSchema = CollectionSchema(
  name: r'UserModel',
  id: 4892048102948102941,
  properties: {
    r'id': PropertySchema(
      id: 0,
      name: r'id',
      type: IsarType.string,
    ),
    r'email': PropertySchema(
      id: 1,
      name: r'email',
      type: IsarType.string,
    ),
    r'fullName': PropertySchema(
      id: 2,
      name: r'fullName',
      type: IsarType.string,
    ),
    r'phone': PropertySchema(
      id: 3,
      name: r'phone',
      type: IsarType.string,
    ),
    r'role': PropertySchema(
      id: 4,
      name: r'role',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 5,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
  },
  estimateSize: _userModelEstimateSize,
  serialize: _userModelSerialize,
  deserialize: _userModelDeserialize,
  deserializeProp: _userModelDeserializeProp,
  idName: r'isarId',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _userModelGetId,
  getLinks: _userModelGetLinks,
  attach: _userModelAttach,
  version: '3.1.0+1',
);

int _userModelEstimateSize(
  UserModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = 0;
  bytesCount += 3 + object.id.length * 3;
  bytesCount += 3 + object.email.length * 3;
  bytesCount += 3 + object.fullName.length * 3;
  bytesCount += 3 + object.phone.length * 3;
  bytesCount += 3 + object.role.length * 3;
  return bytesCount;
}

void _userModelSerialize(
  UserModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.id);
  writer.writeString(offsets[1], object.email);
  writer.writeString(offsets[2], object.fullName);
  writer.writeString(offsets[3], object.phone);
  writer.writeString(offsets[4], object.role);
  writer.writeDateTime(offsets[5], object.updatedAt);
}

UserModel _userModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserModel();
  object.isarId = id;
  object.id = reader.readString(offsets[0]);
  object.email = reader.readString(offsets[1]);
  object.fullName = reader.readString(offsets[2]);
  object.phone = reader.readString(offsets[3]);
  object.role = reader.readString(offsets[4]);
  object.updatedAt = reader.readDateTime(offsets[5]);
  return object;
}

P _userModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown propertyWithId $propertyId');
  }
}
