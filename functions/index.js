const functions = require('firebase-functions');
const cors = require('cors')({ origin: true });
const Busboy = require('busboy');
const os = require('os');
const path = require('path');
const fs = require('fs');
const fbAdmin = require('firebase-admin');
const uuid = require('uuid/v4');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

const gcconfig = {
    projectId: 'flutter-project-70069',
    keyFilename: 'flutter-project.json'
}

const gcs = require('@google-cloud/storage')(gcconfig);
fbAdmin.initializeApp({ credential: fbAdmin.credential.cert(require('./flutter-project.json')) });

exports.storeImage = functions.https.onRequest((req, res) => {

    return cors(req, res, () => {
        if (req.method !== 'POST') {
            return res.status(500).json({ message: 'No allowed' });
        }

        if (!req.headers.authorization || !req.headers.authorization.startsWith('Bearer ')) {
            return res.status(401).json({ message: 'Unauthorized.' });
        }

        let idToken;
        idToken = req.headers.authorization.split('Bearer ')[1];

        const busboy = new Busboy({ headers: req.headers });
        let uploadPath;
        let oldImagePath;

        busboy.on('file', (fieldname, file, filename, encoding, mimetype) => {
            const filepath = path.join(os.tmpdir(), filename);

            uploadPath = { filepath: filepath, type: mimetype, name: filename };
            file.pipe(fs.createWriteStream(filepath));
        });

        busboy.on('filed', (fieldname, value) => {
            oldImagePath = decodeURIComponent(value);
        });

        busboy.on('finish', () => {
            const bucket = gcs.bucket('flutter-project-70069.appspot.com');
            const id = uuid();
            let imagePath = 'images/' + id + uploadPath.name;
            if (oldImagePath) {
                imagePath = oldImagePath;
            }

            return fbAdmin
                .auth()
                .verifyIdToken(idToken)
                .then(decodedToken => {
                    return bucket.upload(uploadPath.filepath, {
                        uploadType: 'media',
                        destination: imagePath,
                        metadata: {
                            metadata: {
                                contentType: uploadPath.type,
                                firebaseStorageDownloadTokens: id
                            }
                        }
                    });
                })
                .then(() => {
                    return res.status(201).json({
                        imageUrl: 'https://firebasestorage.googleapis.com/v0/b/'
                         + bucket.name + '/o/' + encodeURIComponent(imagePath) 
                         + '?alt=media&token=' + id,
                        imagePath: imagePath,
                    })
                })
                .catch(error => {
                    return res.status(401).json({ message: 'Unauthorized.' });
                });
        });
        return busboy.end(req.rawBody);
    });
});

exports.deleteImage = functions.database.ref('/products/{productId}').onDelete(snapshot => {

    const imageData = snapshot.val();
    const imagePath = imageData.imagePath;

    const bucket = gcs.bucket('flutter-project-70069.appspot.com');
    return bucket.file(imagePath).delete() 
});