from google.cloud import firestore

client = firestore.Client()

collections = [collection for collection in client.collections()]

for collection in collections:
    documents = [document for document in collection.list_documents()]
    for document in documents:
        document.delete()
