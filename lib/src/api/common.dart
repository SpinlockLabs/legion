part of legion.api;

class ProviderDescription {
  final String id;
  final String type;
  final String description;

  ProviderDescription(this.id, this.type, this.description);

  factory ProviderDescription.generic(String id, String description) {
    return new ProviderDescription(id, id, description);
  }
}

abstract class Provider {
  Future<ProviderDescription> describe();
}
