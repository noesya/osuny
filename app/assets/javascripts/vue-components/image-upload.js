/* global vueComponents, ActiveStorage */
window.vueComponents = window.vueComponents || {};

vueComponents.imageUpload = {
    name: 'image-upload',
    data: function() {
        return {
            id: null,
            alt: '',
            credit: '',
            blob: null
        }
    },
    props: [
        'upload-url',
        'blob-url-template',
        'prout'
    ],
    methods: {
        onFileImageChange: function (event) {
            'use strict';
            var files = event.target.files || event.dataTransfer.files;
            if (!files.length) {
                return;
            }
            console.log(this.$props);
            this.uploadFile(files[0]);
        },
        uploadFile: function (file) {
            'use strict';

            var url = this.$props.uploadUrl,
                upload = new ActiveStorage.DirectUpload(file, url);

            upload.create(function (error, blob) {
                if (error) {
                    console.log(error);
                } else {
                    this.blob = blob;
                }

                this.onUpdate();

            }.bind(this));

        },
        getImageUrl: function () {
            'use strict';

            return this.$props.blobUrlTemplate
                .replace(':signed_id', this.blob.signed_id)
                .replace(':filename', this.blob.filename);
        },
        onUpdate: function () {
            this.$emit('input', this.id)
        }
    },
    template: `
        <div>
            <img :src="getImageUrl()" class="img-fluid d-block" v-if="blob" />
            <label>
                Image
            </label>
            <input type="file"
                accept="image/*"
                @change="onFileImageChange($event)">
        </div>
        `
};
