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
        'image'
    ],
    mounted: function() {
        console.log(this.$props.image);
        if (this.$props.image) {
            this.$data.blob = this.$props.image.blob;
            this.$data.id = this.$props.image.id;
            this.$data.alt = this.$props.image.alt;
            this.$data.credit = this.$props.image.credit;
        }
    },
    methods: {
        onFileImageChange: function (event) {
            'use strict';
            var files = event.target.files || event.dataTransfer.files;
            if (!files.length) {
                return;
            }
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
            this.$emit('update', {
                id: this.blob.id,
                blob: {
                    signed_id: this.blob.signed_id,
                    filename: this.blob.filename
                },
                alt: this.alt,
                credit: this.credit
            });
        }
    },
    template: `
        <div>
            <img :src="getImageUrl()" class="img-fluid d-block" v-if="blob" />
            <label>
                Image
            </label>
            <input class="form-control"
                type="file"
                accept="image/*"
                @change="onFileImageChange($event)">
            <label>
                Alt
            </label>
            <input class="form-control"
                type="text"
                v-model="alt"
                @input="onUpdate">
            <label>
                Crédit
            </label>
            <input class="form-control"
                type="text"
                v-model="credit"
                @input="onUpdate">
        </div>
        `
};
