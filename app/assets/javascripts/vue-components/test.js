/* global vueComponents */
window.vueComponents = window.vueComponents || {};

// // Create a Vue application
// // var app = Vue.createApp({});

// // // Define a new global component called button-counter
// app.component('button-counter', {
//     data: function () {
//         'use strict';
//         return {
//             count: 0
//         };
//     },
//     template: function () {
//         'use strict';
//         return '<button @click="count++">'
//           + 'You clicked me {{ count }} times.'
//           + '</button>';
//     }
// });


// var vueTitle = Vue.defineComponent({
//     name: 'title',
//     props: ['text'],
//     template: '<h1>{{ text }}</h1>'
// });

// console.log(vueTitle);
// console.log(Vue.defineComponent);


vueComponents.vueTitleComponent = {
    name: 'title',
    props: ['text'],
    template: '<h1>{{ text }}</h1>'
};

vueComponents.vueButtonCounter = {
    data: function () {
        'use strict';
        return {
            count: 0
        };
    },
    template: '<button @click="count++">'
          + 'You clicked me {{ count }} times.'
          + '</button>'
}