___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "GA4 to Meta Commerce Parameter Mapper",
  "categories": [
    "UTILITY",
    "ADVERTISING",
    "DATA_WAREHOUSING"
  ],
  "description": "This GTM template helps you seamlessly map Google Analytics 4 (GA4) e-commerce parameters to the correct format for Meta (Facebook) Pixel.",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "CHECKBOX",
    "name": "persistent",
    "checkboxText": "Persistent",
    "simpleValueType": true,
    "alwaysInSummary": true,
    "displayName": "When checked saves and retrieves the object in localStorage"
  },
  {
    "type": "TEXT",
    "name": "ga4ecommObj",
    "displayName": "GA4 Ecommerce Object",
    "simpleValueType": true,
    "help": "If empty will read from the Data Layer"
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const dl = require('copyFromDataLayer');
const JSON = require('JSON');
const makeInteger = require('makeInteger');
const makeNumber = require('makeNumber');
const ecommerce = data.ga4ecommObj || dl('ecommerce');
const items = ecommerce.items || [];
const localStorage = require('localStorage');
const isPersistent = data.persistent;
if (!ecommerce) {
  return null;
}

const MetaObject = {};
const getItemIDs = (items) => {
  return items.filter(item => item.item_id && typeof(item.item_id) === 'string')
    .map(item => item.item_id);
};

const getContentsArray = (items) => {
  return items.map((item) => ({
    id: item.item_id,
    quantity: makeInteger(item.quantity) || 1,
    item_price: makeNumber(item.price)
  }));
};

const getValue = (items) => {
  return items.reduce((a,c) => {
    const v = c.quantity*c.price;
    if(v) return a+v;},0);
};

MetaObject.currency = ecommerce.currency;
MetaObject.value = makeNumber(ecommerce.value) || getValue(items);
MetaObject.content_ids = getItemIDs(items);
MetaObject.contents = getContentsArray(items);
MetaObject.num_items = ecommerce.items.length;
if (items.length > 0) {
  MetaObject.content_type = items.length > 1 ? 'product_group' : 'product';
}
if (ecommerce.transaction_id) {
  MetaObject.order_id = ecommerce.transaction_id;
}
if (isPersistent) {
  localStorage.setItem('metaObject', JSON.stringify(MetaObject));
  return JSON.parse(localStorage.getItem('metaObject'));
}


return MetaObject;


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "read_data_layer",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedKeys",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "keyPatterns",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "ecommerce"
              },
              {
                "type": 1,
                "string": "event"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "access_local_storage",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keys",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "key"
                  },
                  {
                    "type": 1,
                    "string": "read"
                  },
                  {
                    "type": 1,
                    "string": "write"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "metaObject"
                  },
                  {
                    "type": 8,
                    "boolean": true
                  },
                  {
                    "type": 8,
                    "boolean": true
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Output is Equal to Expected
  code: |-
    testCases.forEach(testCase => {
      mock('logToConsole', log);
      mock('copyFromDataLayer', (key) => testCase.data[key]);
      mock('makeInteger', makeInteger);
      mock('makeNumber', makeNumber);
      const result = runCode();
      assertThat(result).isNotEqualTo(null);
      assertThat(result).isEqualTo(testCase.expected);
    });
setup: |-
  const makeInteger = require('makeInteger');
  const makeNumber = require('makeNumber');
  const log = require('logToConsole');
  // Definisci i test case per diversi eventi
  const testCases = [
    {
      name: "Test 'begin_checkout' event",
      data: {
        event: "begin_checkout",
        ecommerce: {
          currency: "USD",
          value: 30.03,
          items: [
            { item_id: "SKU_12345", price: 10.01, quantity: 3 }
          ]
        }
      },
      expected: {
        currency: "USD",
        value: 30.03,
        content_ids: ["SKU_12345"],
        contents: [{id: "SKU_12345", item_price: 10.01, quantity: 3}],
        num_items: 1,
        content_type: "product"
      }
    },
    {
      name: "Test 'purchase' event with multiple items",
      data: {
        event: "purchase",
        ecommerce: {
          currency: "EUR",
          value: 50.00,
          transaction_id: "T_45678",
          items: [
            { item_id: "A_1", price: 20.00, quantity: 1 },
            { item_id: "B_2", price: 15.00, quantity: 2 }
          ]
        }
      },
      expected: {
        currency: "EUR",
        value: 50.00,
        content_ids: ["A_1", "B_2"],
        contents: [{id: "A_1", item_price: 20, quantity: 1}, {id: "B_2", item_price: 15, quantity: 2}],
        content_type: "product_group",
        order_id: "T_45678"
      }
    }
  ];


___NOTES___

Created on 12/09/2025, 13:43:49


