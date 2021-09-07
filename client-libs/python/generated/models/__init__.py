# flake8: noqa

# import all models into this package
# if you have many models here with many references from one model to another this may
# raise a RecursionError
# to avoid this, import only the models that you directly need like:
# from from generated.model.pet import Pet
# or import this package, but before doing it, use:
# import sys
# sys.setrecursionlimit(n)

from generated.model.approver import Approver
from generated.model.campaign import Campaign
from generated.model.cause import Cause
from generated.model.donation import Donation
from generated.model.donor import Donor
