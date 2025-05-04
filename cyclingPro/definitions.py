from dagster import Definitions
import cyclingPro.transformation.definitions as transformation_definitions
import cyclingPro.ingestion.definitions as ingestion_definitions

from dotenv import load_dotenv
load_dotenv()

defs = Definitions.merge(
    ingestion_definitions.defs, transformation_definitions.defs
)


