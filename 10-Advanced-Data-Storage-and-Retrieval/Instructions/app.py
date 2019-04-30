from flask import Flask,jsonify
import datetime as dt

# Python SQL toolkit and Object Relational Mapper
import sqlalchemy
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session
from sqlalchemy import create_engine, func
from sqlalchemy.pool import StaticPool

engine = create_engine("sqlite:///Resources/hawaii.sqlite", connect_args={'check_same_thread': False}, poolclass=StaticPool, echo=True)

# reflect an existing database into a new model
Base = automap_base()
# reflect the tables
Base.prepare(engine, reflect=True)

# Save references to each table
Measurement = Base.classes.measurement
Station = Base.classes.station

# Create our session (link) from Python to the DB
session = Session(engine)

query_date = dt.date(2017, 8, 23) - dt.timedelta(days=365)
prcp = session.query(Measurement.prcp, Measurement.date).filter(Measurement.date>query_date).order_by\
(Measurement.date).all()
station = session.query(Measurement.station).all()
USC00519281_temps = session.query(Measurement.date, Measurement.tobs).filter(Measurement.station == 'USC00519281').\
filter(Measurement.date>query_date).order_by(Measurement.date).all()

app = Flask(__name__)

@app.route("/")
def home():
    return (
        f"Routes in this api:<br/><br/>"
        f"/api/v1.0/precipitation<br/>"
        f"/api/v1.0/stations<br/>"
        f"/api/v1.0/tobs<br/>"
        f"/api/v1.0/start<br/>"
        f"/api/v1.0/start/end"
    )

@app.route("/api/v1.0/precipitation")
def precipitation():
    return jsonify(prcp)

@app.route("/api/v1.0/stations")
def stations():
    return jsonify(station)

@app.route("/api/v1.0/tobs")
def tobs():
    return jsonify(USC00519281_temps)

@app.route("/api/v1.0/<start>")
def start(start):

    start_date = dt.datetime.strptime (start, "%Y-%m-%d") - dt.timedelta(days=365)
    temp = session.query(func.min(Measurement.tobs), func.avg(Measurement.tobs), func.max(Measurement.tobs)).\
        filter(Measurement.date >= start_date).all()
    return jsonify(temp)

@app.route("/api/v1.0/<start>/<end>")
def startEnd(start, end):

    start_date = dt.datetime.strptime (start, "%Y-%m-%d") - dt.timedelta(days=365)
    end_date = dt.datetime.strptime (end, "%Y-%m-%d") - dt.timedelta(days=365)
    temp = session.query(func.min(Measurement.tobs), func.avg(Measurement.tobs), func.max(Measurement.tobs)).\
        filter(Measurement.date >= start_date).filter(Measurement.date <= end_date).all()
    return jsonify(temp)


if __name__ == "__main__":
    app.run(debug=True)