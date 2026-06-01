# Pipeline Architecture

The project uses a medallion architecture:

- Bronze stores raw imported records.
- Silver stores cleaned and validated records.
- Gold stores analytics-ready reporting tables.
