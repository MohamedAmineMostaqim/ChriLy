from pathlib import Path
import numpy as np
import pandas as pd

# ==========================================================
# Configuration
# ==========================================================

RANDOM_STATE = 42
BRL_TO_MAD = 1.83

rng = np.random.default_rng(RANDOM_STATE)

ROOT = Path(__file__).resolve().parent.parent

RAW_PATH = ROOT / "data" / "raw"
RESOURCE_PATH = ROOT / "resources" / "morocco"
OUTPUT_PATH = ROOT / "data" / "morocco"

OUTPUT_PATH.mkdir(
    parents=True,
    exist_ok=True
)


# ==========================================================
# Load Raw Datasets
# ==========================================================

customers = pd.read_csv(
    RAW_PATH / "olist_customers_dataset.csv"
)

geolocation = pd.read_csv(
    RAW_PATH / "olist_geolocation_dataset.csv"
)

order_items = pd.read_csv(
    RAW_PATH / "olist_order_items_dataset.csv"
)

order_payments = pd.read_csv(
    RAW_PATH / "olist_order_payments_dataset.csv"
)

order_reviews = pd.read_csv(
    RAW_PATH / "olist_order_reviews_dataset.csv"
)

orders = pd.read_csv(
    RAW_PATH / "olist_orders_dataset.csv"
)

products = pd.read_csv(
    RAW_PATH / "olist_products_dataset.csv"
)

sellers = pd.read_csv(
    RAW_PATH / "olist_sellers_dataset.csv"
)

category_translation = pd.read_csv(
    RAW_PATH / "product_category_name_translation.csv"
)


# ==========================================================
# Load Resources
# ==========================================================

region_mapping = pd.read_csv(
    RESOURCE_PATH / "region_mapping.csv"
)

morocco_cities = pd.read_csv(
    RESOURCE_PATH / "morocco_cities.csv"
)

payment_mapping = pd.read_csv(
    RESOURCE_PATH / "payment_mapping.csv"
)

category_mapping = pd.read_csv(
    RESOURCE_PATH / "category_mapping.csv"
)

carrier_mapping = pd.read_csv(
    RESOURCE_PATH / "carrier_mapping.csv"
)

holiday_calendar = pd.read_csv(
    RESOURCE_PATH / "holiday_calendar.csv"
)


# ==========================================================
# Original Row Counts
# ==========================================================

original_counts = {
    "customers": len(customers),
    "geolocation": len(geolocation),
    "order_items": len(order_items),
    "order_payments": len(order_payments),
    "order_reviews": len(order_reviews),
    "orders": len(orders),
    "products": len(products),
    "sellers": len(sellers),
    "category_translation": len(category_translation),
}


# ==========================================================
# Dictionaries
# ==========================================================

region_dict = dict(
    zip(
        region_mapping["brazil_state"],
        region_mapping["morocco_region"],
    )
)

payment_dict = dict(
    zip(
        payment_mapping["original_payment"],
        payment_mapping["localized_payment"],
    )
)

category_dict = dict(
    zip(
        category_mapping["original_category"],
        category_mapping["chrily_category"],
    )
)


# ==========================================================
# Currency Conversion
# ==========================================================

order_items["price"] = (
    order_items["price"] * BRL_TO_MAD
).round(2)

order_items["freight_value"] = (
    order_items["freight_value"] * BRL_TO_MAD
).round(2)

order_payments["payment_value"] = (
    order_payments["payment_value"] * BRL_TO_MAD
).round(2)

print("✓ Currency converted to MAD")

# ==========================================================
# Geography Localization
# ==========================================================

customers["customer_state"] = (
    customers["customer_state"]
    .map(region_dict)
)

sellers["seller_state"] = (
    sellers["seller_state"]
    .map(region_dict)
)

geolocation["geolocation_state"] = (
    geolocation["geolocation_state"]
    .map(region_dict)
)


# ==========================================================
# Moroccan City Pools
# ==========================================================

city_pool = {}

for region in morocco_cities["region"].unique():

    city_pool[region] = (
        morocco_cities[
            morocco_cities["region"] == region
        ]
        .reset_index(drop=True)
    )


# ==========================================================
# Deterministic City Mapping
# ==========================================================

location_mapping = {}

all_locations = pd.concat(
    [

        customers[
            [
                "customer_state",
                "customer_city"
            ]
        ].rename(
            columns={
                "customer_state": "state",
                "customer_city": "city"
            }
        ),

        sellers[
            [
                "seller_state",
                "seller_city"
            ]
        ].rename(
            columns={
                "seller_state": "state",
                "seller_city": "city"
            }
        ),

        geolocation[
            [
                "geolocation_state",
                "geolocation_city"
            ]
        ].rename(
            columns={
                "geolocation_state": "state",
                "geolocation_city": "city"
            }
        )

    ]
)

all_locations = (
    all_locations
    .drop_duplicates()
    .reset_index(drop=True)
)

for _, row in all_locations.iterrows():

    state = row["state"]
    city = row["city"]

    choices = city_pool[state]

    selected = choices.sample(
        n=1,
        weights="weight",
        random_state=abs(hash(city)) % (2**32)
    ).iloc[0]

    location_mapping[(state, city)] = {

        "city": selected["city"],

        "zip": selected["postal_code"],

        "lat": selected["latitude"],

        "lng": selected["longitude"]

    }

print(
    f"✓ {len(location_mapping):,} cities mapped"
)


def map_customer(row):

    return location_mapping[
        (
            row["customer_state"],
            row["customer_city"]
        )
    ]

mapped = customers.apply(
    map_customer,
    axis=1
)

customers["customer_city"] = [
    x["city"] for x in mapped
]

customers["customer_zip_code_prefix"] = [
    x["zip"] for x in mapped
]

print("✓ Customers localized")


def map_seller(row):

    return location_mapping[
        (
            row["seller_state"],
            row["seller_city"]
        )
    ]

mapped = sellers.apply(
    map_seller,
    axis=1
)

sellers["seller_city"] = [
    x["city"] for x in mapped
]

sellers["seller_zip_code_prefix"] = [
    x["zip"] for x in mapped
]

print("✓ Sellers localized")


def map_geo(row):

    return location_mapping[
        (
            row["geolocation_state"],
            row["geolocation_city"]
        )
    ]

mapped = geolocation.apply(
    map_geo,
    axis=1
)

geolocation["geolocation_city"] = [
    x["city"] for x in mapped
]

geolocation["geolocation_zip_code_prefix"] = [
    x["zip"] for x in mapped
]

geolocation["geolocation_lat"] = [
    x["lat"] for x in mapped
]

geolocation["geolocation_lng"] = [
    x["lng"] for x in mapped
]

print("✓ Geolocation localized")


# ==========================================================
# Product Categories
# ==========================================================

products["product_category_name"] = (
    products["product_category_name"]
    .replace(category_dict)
)

category_translation = (
    category_translation
    .merge(
        category_mapping,
        left_on="product_category_name",
        right_on="original_category",
        how="left"
    )
)

category_translation["product_category_name_english"] = (
    category_translation["chrily_category"]
    .fillna(
        category_translation["product_category_name_english"]
    )
)

category_translation = category_translation[
    [
        "product_category_name",
        "product_category_name_english"
    ]
]

print("✓ Categories localized")


# ==========================================================
# Payment Methods
# ==========================================================

order_payments["payment_type"] = (
    order_payments["payment_type"]
    .replace(payment_dict)
)

print("✓ Payment methods localized")


# ==========================================================
# Assign Preferred Carrier to Sellers
# ==========================================================

carrier_weights = (
    carrier_mapping["weight"] /
    carrier_mapping["weight"].sum()
)

seller_carriers = pd.DataFrame({

    "seller_id": sellers["seller_id"],

    "carrier_name": rng.choice(

        carrier_mapping["carrier_name"],

        size=len(sellers),

        p=carrier_weights

    )

})

print("✓ Preferred carrier assigned to each seller")


# ==========================================================
# Attach Carrier to Order Items
# ==========================================================

order_items = order_items.merge(

    seller_carriers,

    on="seller_id",

    how="left"

)

print("✓ Carrier added to every order item")

# ==========================================================
# Tracking Numbers
# ==========================================================

carrier_codes = {

    "Amana": "AMN",

    "Aramex": "ARX",

    "Catoni": "CAT",

    "Speedaf": "SPD",

    "Jumia Logistics": "JML"

}


def generate_tracking_number(carrier):

    prefix = carrier_codes.get(
        carrier,
        "CHR"
    )

    year = rng.choice(
        [2024, 2025, 2026]
    )

    serial = rng.integers(
        10000000,
        99999999
    )

    return f"{prefix}-{year}-{serial}"


order_items["tracking_number"] = (

    order_items["carrier_name"]

    .apply(generate_tracking_number)

)

print("✓ Tracking numbers generated")


# ==========================================================
# Moroccan Phone Numbers
# ==========================================================

def generate_phone():

    prefix = rng.choice(
        ["6", "7"]
    )

    number = rng.integers(
        10000000,
        99999999
    )

    return f"+212{prefix}{number}"


customers["customer_phone"] = [
    generate_phone()
    for _ in range(len(customers))
]

print("✓ Phone numbers generated")


# ==========================================================
# WhatsApp Confirmation
# ==========================================================

orders["whatsapp_confirmed"] = False

delivered_mask = orders["order_status"] == "delivered"
shipped_mask = orders["order_status"] == "shipped"
processing_mask = orders["order_status"] == "processing"
cancelled_mask = orders["order_status"] == "canceled"

orders.loc[
    delivered_mask,
    "whatsapp_confirmed"
] = (
    rng.random(delivered_mask.sum()) < 0.95
)

orders.loc[
    shipped_mask,
    "whatsapp_confirmed"
] = (
    rng.random(shipped_mask.sum()) < 0.90
)

orders.loc[
    processing_mask,
    "whatsapp_confirmed"
] = (
    rng.random(processing_mask.sum()) < 0.70
)

orders.loc[
    cancelled_mask,
    "whatsapp_confirmed"
] = (
    rng.random(cancelled_mask.sum()) < 0.25
)

print("✓ WhatsApp confirmation generated")


# ==========================================================
# Cancellation Reasons
# ==========================================================

orders["cancellation_reason"] = pd.NA

reasons = [

    "Client unreachable",

    "COD refused",

    "Incorrect address",

    "Customer requested cancellation",

    "Duplicate order"

]

orders.loc[
    cancelled_mask,
    "cancellation_reason"
] = rng.choice(
    reasons,
    size=cancelled_mask.sum()
)

print("✓ Cancellation reasons generated")


# ==========================================================
# Shift Dates (+8 Years)
# ==========================================================

date_tables = [

    (
        orders,
        [
            "order_purchase_timestamp",
            "order_approved_at",
            "order_delivered_carrier_date",
            "order_delivered_customer_date",
            "order_estimated_delivery_date"
        ]
    ),

    (
        order_items,
        [
            "shipping_limit_date"
        ]
    ),

    (
        order_reviews,
        [
            "review_creation_date",
            "review_answer_timestamp"
        ]
    )

]

for dataframe, columns in date_tables:

    for column in columns:

        dataframe[column] = pd.to_datetime(
            dataframe[column],
            errors="coerce"
        )

        dataframe[column] += pd.DateOffset(years=8)

print("✓ Dates shifted to 2024–2026")

# ==========================================================
# Holiday Enrichment
# ==========================================================

holiday_calendar["date"] = pd.to_datetime(
    holiday_calendar["date"]
)

orders["purchase_date"] = (
    orders["order_purchase_timestamp"]
    .dt.normalize()
)

orders = orders.merge(

    holiday_calendar,

    left_on="purchase_date",

    right_on="date",

    how="left"

)

orders["is_holiday"] = (
    orders["holiday"]
    .notna()
)

orders["is_ramadan"] = (
    orders["holiday"]
    .fillna("")
    .str.contains("Ramadan", case=False)
)

orders.drop(
    columns=["date"],
    inplace=True
)

print("✓ Holiday information added")


# ==========================================================
# Validation
# ==========================================================

print("\n" + "=" * 60)
print("VALIDATION")
print("=" * 60)

current_counts = {

    "customers": len(customers),

    "geolocation": len(geolocation),

    "order_items": len(order_items),

    "order_payments": len(order_payments),

    "order_reviews": len(order_reviews),

    "orders": len(orders),

    "products": len(products),

    "sellers": len(sellers),

    "category_translation": len(category_translation)

}

validation = pd.DataFrame({

    "Dataset": original_counts.keys(),

    "Original Rows": original_counts.values(),

    "Localized Rows": current_counts.values()

})

validation["Passed"] = (

    validation["Original Rows"]

    ==

    validation["Localized Rows"]

)

print(validation)

print()

if validation["Passed"].all():

    print("✓ Row count validation passed")

else:

    print("⚠ Row count mismatch detected")


print("\nCurrency Statistics")

print(

    order_items[

        [

            "price",

            "freight_value"

        ]

    ].describe()

)

print()

print(

    order_payments[

        [

            "payment_value"

        ]

    ].describe()

)


print("\nGeography Statistics")

print(

    customers["customer_state"]

    .value_counts()

)

print()

print(

    sellers["seller_state"]

    .value_counts()

)


print("\nWhatsApp Confirmation")

print(

    orders["whatsapp_confirmed"]

    .value_counts()

)


print("\nCarrier Distribution")

print(

    order_items["carrier_name"]

    .value_counts()

)


# ==========================================================
# Export Localized Datasets
# ==========================================================

datasets = {

    "chrily_customers.csv": customers,

    "chrily_geolocation.csv": geolocation,

    "chrily_order_items.csv": order_items,

    "chrily_order_payments.csv": order_payments,

    "chrily_order_reviews.csv": order_reviews,

    "chrily_orders.csv": orders,

    "chrily_products.csv": products,

    "chrily_sellers.csv": sellers,

    "chrily_category_translation.csv": category_translation

}

for filename, dataframe in datasets.items():

    dataframe.to_csv(
        OUTPUT_PATH / filename,
        index=False
    )

print("✓ ChriLy datasets exported successfully.")


# ==========================================================
# Pipeline Summary
# ==========================================================

print("\n" + "=" * 60)
print("CHRILY MOROCCANIZATION PIPELINE")
print("=" * 60)

print(f"Customers              : {len(customers):,}")
print(f"Sellers                : {len(sellers):,}")
print(f"Products               : {len(products):,}")
print(f"Orders                 : {len(orders):,}")
print(f"Order Items            : {len(order_items):,}")
print(f"Payments               : {len(order_payments):,}")
print(f"Reviews                : {len(order_reviews):,}")
print(f"Geolocation Records    : {len(geolocation):,}")

print("\nApplied Transformations")
print("------------------------------")

transformations = [

    "Currency converted (BRL → MAD)",
    "States mapped to Moroccan regions",
    "Cities localized",
    "ZIP codes localized",
    "Coordinates localized",
    "Product categories localized",
    "Payment methods localized",
    "Preferred carrier assigned",
    "Tracking numbers generated",
    "Customer phone numbers generated",
    "WhatsApp confirmation generated",
    "Cancellation reasons generated",
    "Dates shifted (+8 years)",
    "Holiday enrichment completed"

]

for item in transformations:

    print(f"✓ {item}")

print("\nOutput Folder")

print(OUTPUT_PATH)

print("\nPipeline completed successfully.")

print("=" * 60)