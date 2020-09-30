import sys

from pyspark.sql import SparkSession

if len(sys.argv) > 1:
    INPUT_LOCATION = sys.argv[1]
    OUTPUT_LOCATION = sys.argv[2]
else:
    print("Usage: spark_converter <input> <output>")
    sys.exit(-1)

# Utility to just take an input file and split it
if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: spark_converter <input> <output>")
        sys.exit(-1)
    
    # Initialize the spark context.
    spark = SparkSession\
        .builder\
        .appName("SparkConverter")\
        .getOrCreate()
    
    # Read in the desired TSV
    df = spark.read.option('sep', '\t').option('header', 'true').csv(INPUT_LOCATION)

    # Just to put some pressure on memory
    df.groupBy('product_category').count().show()

    # Repartition for multiple output files and write out to parquet
    df.repartition(10).write.mode('overwrite').parquet(OUTPUT_LOCATION)