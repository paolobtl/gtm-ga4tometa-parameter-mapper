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
const localStorage = require('localStorage');
const toString = require('makeString');

// --- Configuration ---
const ecommerce = data.ga4ecommObj || dl('ecommerce');
const isPersistent = data.persistent;

// --- Guard Clauses ---
if (!ecommerce) {
  return null;
}

const items = ecommerce.items || [];

if (items.length === 0) {
  return null;
}

// --- Helper Functions ---
const getItemIDs = (itemList) => {
  return itemList
    .filter(item => item.item_id)
    .map(item => toString(item.item_id));
};

const getContentsArray = (itemList) => {
  return itemList.map((item) => ({
    id: item.item_id,
    quantity: makeInteger(item.quantity) || 1,
    item_price: makeNumber(item.price)
  }));
};

const calculateValueFromItems = (itemList) => {
  return itemList.reduce((accumulator, currentItem) => {
    const value = (currentItem.quantity || 1) * currentItem.price;
    if (value) {
      return accumulator + value;
    }
    return accumulator;
  }, 0);
};

// --- Main Logic ---
const MetaObject = {};

MetaObject.currency = ecommerce.currency;
MetaObject.value = makeNumber(ecommerce.value) || calculateValueFromItems(items);
MetaObject.content_ids = getItemIDs(items);
MetaObject.contents = getContentsArray(items);
MetaObject.num_items = items.length;

MetaObject.content_type = items.length > 1 ? 'product_group' : 'product';

if (ecommerce.transaction_id) {
  MetaObject.order_id = ecommerce.transaction_id;
}

if (isPersistent) {
  localStorage.setItem('metaObject', JSON.stringify(MetaObject));
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

scenarios: []
setup: ''


___NOTES___

Created on 12/09/2025, 13:43:49


