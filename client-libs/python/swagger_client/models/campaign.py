# coding: utf-8

"""
    Emblem API

    REST API for any Emblem server  # noqa: E501

    OpenAPI spec version: 2021-07-07
    
    Generated by: https://github.com/swagger-api/swagger-codegen.git
"""

import pprint
import re  # noqa: F401

import six

class Campaign(object):
    """NOTE: This class is auto generated by the swagger code generator program.

    Do not edit the class manually.
    """
    """
    Attributes:
      swagger_types (dict): The key is attribute name
                            and the value is attribute type.
      attribute_map (dict): The key is attribute name
                            and the value is json key in definition.
    """
    swagger_types = {
        'id': 'str',
        'name': 'str',
        'description': 'str',
        'cause': 'str',
        'managers': 'list[str]',
        'goal': 'float',
        'image_url': 'str',
        'active': 'bool',
        'time_created': 'datetime',
        'updated': 'datetime',
        'self_link': 'str'
    }

    attribute_map = {
        'id': 'id',
        'name': 'name',
        'description': 'description',
        'cause': 'cause',
        'managers': 'managers',
        'goal': 'goal',
        'image_url': 'imageUrl',
        'active': 'active',
        'time_created': 'timeCreated',
        'updated': 'updated',
        'self_link': 'selfLink'
    }

    def __init__(self, id=None, name=None, description=None, cause=None, managers=None, goal=None, image_url=None, active=None, time_created=None, updated=None, self_link=None):  # noqa: E501
        """Campaign - a model defined in Swagger"""  # noqa: E501
        self._id = None
        self._name = None
        self._description = None
        self._cause = None
        self._managers = None
        self._goal = None
        self._image_url = None
        self._active = None
        self._time_created = None
        self._updated = None
        self._self_link = None
        self.discriminator = None
        if id is not None:
            self.id = id
        if name is not None:
            self.name = name
        if description is not None:
            self.description = description
        if cause is not None:
            self.cause = cause
        if managers is not None:
            self.managers = managers
        if goal is not None:
            self.goal = goal
        if image_url is not None:
            self.image_url = image_url
        if active is not None:
            self.active = active
        if time_created is not None:
            self.time_created = time_created
        if updated is not None:
            self.updated = updated
        if self_link is not None:
            self.self_link = self_link

    @property
    def id(self):
        """Gets the id of this Campaign.  # noqa: E501

        unique, system-assigned identifier  # noqa: E501

        :return: The id of this Campaign.  # noqa: E501
        :rtype: str
        """
        return self._id

    @id.setter
    def id(self, id):
        """Sets the id of this Campaign.

        unique, system-assigned identifier  # noqa: E501

        :param id: The id of this Campaign.  # noqa: E501
        :type: str
        """

        self._id = id

    @property
    def name(self):
        """Gets the name of this Campaign.  # noqa: E501

        the campaign's display name  # noqa: E501

        :return: The name of this Campaign.  # noqa: E501
        :rtype: str
        """
        return self._name

    @name.setter
    def name(self, name):
        """Sets the name of this Campaign.

        the campaign's display name  # noqa: E501

        :param name: The name of this Campaign.  # noqa: E501
        :type: str
        """

        self._name = name

    @property
    def description(self):
        """Gets the description of this Campaign.  # noqa: E501

        the purpose of the campaign  # noqa: E501

        :return: The description of this Campaign.  # noqa: E501
        :rtype: str
        """
        return self._description

    @description.setter
    def description(self, description):
        """Sets the description of this Campaign.

        the purpose of the campaign  # noqa: E501

        :param description: The description of this Campaign.  # noqa: E501
        :type: str
        """

        self._description = description

    @property
    def cause(self):
        """Gets the cause of this Campaign.  # noqa: E501

        the id of the Cause this campaign is for  # noqa: E501

        :return: The cause of this Campaign.  # noqa: E501
        :rtype: str
        """
        return self._cause

    @cause.setter
    def cause(self, cause):
        """Sets the cause of this Campaign.

        the id of the Cause this campaign is for  # noqa: E501

        :param cause: The cause of this Campaign.  # noqa: E501
        :type: str
        """

        self._cause = cause

    @property
    def managers(self):
        """Gets the managers of this Campaign.  # noqa: E501


        :return: The managers of this Campaign.  # noqa: E501
        :rtype: list[str]
        """
        return self._managers

    @managers.setter
    def managers(self, managers):
        """Sets the managers of this Campaign.


        :param managers: The managers of this Campaign.  # noqa: E501
        :type: list[str]
        """

        self._managers = managers

    @property
    def goal(self):
        """Gets the goal of this Campaign.  # noqa: E501

        the fundraising goal, in USD  # noqa: E501

        :return: The goal of this Campaign.  # noqa: E501
        :rtype: float
        """
        return self._goal

    @goal.setter
    def goal(self, goal):
        """Sets the goal of this Campaign.

        the fundraising goal, in USD  # noqa: E501

        :param goal: The goal of this Campaign.  # noqa: E501
        :type: float
        """

        self._goal = goal

    @property
    def image_url(self):
        """Gets the image_url of this Campaign.  # noqa: E501

        location of image to display for the campaign  # noqa: E501

        :return: The image_url of this Campaign.  # noqa: E501
        :rtype: str
        """
        return self._image_url

    @image_url.setter
    def image_url(self, image_url):
        """Sets the image_url of this Campaign.

        location of image to display for the campaign  # noqa: E501

        :param image_url: The image_url of this Campaign.  # noqa: E501
        :type: str
        """

        self._image_url = image_url

    @property
    def active(self):
        """Gets the active of this Campaign.  # noqa: E501

        is this campaign accepting donations at this time?  # noqa: E501

        :return: The active of this Campaign.  # noqa: E501
        :rtype: bool
        """
        return self._active

    @active.setter
    def active(self, active):
        """Sets the active of this Campaign.

        is this campaign accepting donations at this time?  # noqa: E501

        :param active: The active of this Campaign.  # noqa: E501
        :type: bool
        """

        self._active = active

    @property
    def time_created(self):
        """Gets the time_created of this Campaign.  # noqa: E501

        system-assigned creation timestamp  # noqa: E501

        :return: The time_created of this Campaign.  # noqa: E501
        :rtype: datetime
        """
        return self._time_created

    @time_created.setter
    def time_created(self, time_created):
        """Sets the time_created of this Campaign.

        system-assigned creation timestamp  # noqa: E501

        :param time_created: The time_created of this Campaign.  # noqa: E501
        :type: datetime
        """

        self._time_created = time_created

    @property
    def updated(self):
        """Gets the updated of this Campaign.  # noqa: E501

        system-assigned update timestamp  # noqa: E501

        :return: The updated of this Campaign.  # noqa: E501
        :rtype: datetime
        """
        return self._updated

    @updated.setter
    def updated(self, updated):
        """Sets the updated of this Campaign.

        system-assigned update timestamp  # noqa: E501

        :param updated: The updated of this Campaign.  # noqa: E501
        :type: datetime
        """

        self._updated = updated

    @property
    def self_link(self):
        """Gets the self_link of this Campaign.  # noqa: E501

        full URI of the resource  # noqa: E501

        :return: The self_link of this Campaign.  # noqa: E501
        :rtype: str
        """
        return self._self_link

    @self_link.setter
    def self_link(self, self_link):
        """Sets the self_link of this Campaign.

        full URI of the resource  # noqa: E501

        :param self_link: The self_link of this Campaign.  # noqa: E501
        :type: str
        """

        self._self_link = self_link

    def to_dict(self):
        """Returns the model properties as a dict"""
        result = {}

        for attr, _ in six.iteritems(self.swagger_types):
            value = getattr(self, attr)
            if isinstance(value, list):
                result[attr] = list(map(
                    lambda x: x.to_dict() if hasattr(x, "to_dict") else x,
                    value
                ))
            elif hasattr(value, "to_dict"):
                result[attr] = value.to_dict()
            elif isinstance(value, dict):
                result[attr] = dict(map(
                    lambda item: (item[0], item[1].to_dict())
                    if hasattr(item[1], "to_dict") else item,
                    value.items()
                ))
            else:
                result[attr] = value
        if issubclass(Campaign, dict):
            for key, value in self.items():
                result[key] = value

        return result

    def to_str(self):
        """Returns the string representation of the model"""
        return pprint.pformat(self.to_dict())

    def __repr__(self):
        """For `print` and `pprint`"""
        return self.to_str()

    def __eq__(self, other):
        """Returns true if both objects are equal"""
        if not isinstance(other, Campaign):
            return False

        return self.__dict__ == other.__dict__

    def __ne__(self, other):
        """Returns true if both objects are not equal"""
        return not self == other
