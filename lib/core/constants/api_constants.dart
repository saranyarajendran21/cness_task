/// API configuration constants and endpoint paths.
class ApiConstants {
  ApiConstants._();

  static const String baseUrl =
      'https://z3z1ppsdij.execute-api.us-east-1.amazonaws.com';

  static const Duration connectTimeout = Duration(seconds: 25);

  // Auth endpoints
  static const String loginPath = '/api/auth/login';

  // Dashboard endpoints
  static const String storiesPath = '/api/story';
  static const String homeFeedPath = '/api/user/posts/get/front/latest';

  // Profile endpoints
  static const String profilePath = '/api/profile';

  // Default pagination
  static const int defaultPage = 1;
  static const int defaultLimit = 10;

  // Provided integration Bearer token for protected endpoints
  static const String defaultAuthToken =
      'jnwNsLduDmrJuz7E9EaWYPxbAYs3rJoktrDcXlJNUaqbVga/ZCkTrBtZsZbJWsHUXSsYaW6NrVKOapdguBP8r9tDgZ8JcUrSsIU/InCdIDp6Pkm3iFCbLkEDHmEiXeQQ9vVuc84ka34PIz3Hmg9ZeyYkxscAG1ngC15PVT6wvb7fULg0ckUwJk5fCkOP9zYcFJD8zL0ktxveDct79wCsDWF3ZISC2LO7tfY4s5GeDGR2gomiIFrCT3vqvTsW1TsbVEPCYKQ+yqSiH1e2Mu89cZx4x11540kuVhBS+dxaSsR/LcC9m1ZXoR69i22LMOdjQ7lj0zKNc2bbxEBrCHXwgS76D76oYbKDZaaWl3Up0wyjZiIBeq/KMKwLiDCPfxsxxxyPXAIlpQsKOuCY5d90nj6bmnxkNuKvGNzsdKBRATIllQf2qSxjCgL9e86EZDu9mHOpa3I6E02tLf/0B2ng5iSCqcPXnZqQ/PAjfG0LCen+euqhy+ceA0k9ULyYGdengAeljmCxK7iaei1J9Jr0kASPhJ8sLZD06obNhELbteQIsy2SaXONl4Q6xRSGeHWDrEW8EAYy2rZ6YeCD5dRSNisBRS8CYb1PxGK6mWWCm1Ex4ff3Xrwjusz0+HRwWNwlE3c6JT4f9h6EW5tjJB6KVyuYDWjyGBsBE04puO+NDhEZRcYaQMOJvtDwI9h+6DyDc3Z6j8ZVGLA3hODWzG0lQpvy5utLCD7eV+pJEuOyzlSDA9Hpk87v/eyFOtzpJs0xiXRgAwopiSJYR4ydv/DWAljjpTlgxUkMywV1lhiWFhKKvHn2ZQbfoqgJObikNWyBUhL8LuLh9Mq5P1qo57EYBS9yNGSJOTLOSnqidlbnF6ysOjcuFg2nWQJ8rR6fTzf5Ei+5OcqMg4kqRlN+uw/PPCFkl4T1RdfoSsQNH7EjQPK0NbszRhQVTobe29vIDpXVMFYJ7L8EfoKOHfPCZmNHIMbEs0J55xrhmDv3VXqvo7Cg1A7sDK+B52Ib2Cncvmpum2hQhG1MOb/DWO0WrnsyD7TztEljth913/e7xyCoF1l6wzzTyHpJBVH+pV84gT/SZWjixgEOBuCOdhduFlEJdcdu2GDhZ3ILM/lHAXWvCx242XjFUXNUdXADkSVp6sJqDsFdpo2tLYn0tT1ea4f6P+wjbK09FvPIeMs5AgGvVvBNWaHuOkmPkB9i0EHUL59sa4656DbZxh43kk0qXLpK1z0pNPc/ierOupVF8OLRUUqlmCOFIbzvsN54DEH4II0oOZDeyABxN2+w013qChwUPVGqfUk3/PXcNiQxQwxMyFyoVGDdrbf69sdPWyf4+FEOsIo7a+o4W5AZzO35wL9U4rh83WdHL+Q2dN3HYzySIm6n/YT/eqF7EuPjHQEUIDxIB9p+NfJY0BczoyEByzsahd6jBvVjuFwfrrWOPSgyxw8G89vzgGoyyV/o9f1G0I87NFDky0Hz8jMAuvCz1bctrQcvzBRYQplo3G6pB6ZZgKnI00QJn+c0vgG+sWOpT87Lq9o0wkpSJm7/df0lIu2npfUxy1GJ0tvnwh/WbJKbpMOIgZSZc2QElQnIBPVfVAh9TQKQU3js+bNsssA9EZmcH++6ZX6aLJLagyCMDSVMhQi4ijaTj8Maj+VukQUwZMonL2hQhMPFpxuLCzomFJ0TwaZZ4EomQ/I1Ta8tR1uBd63/2ItZLN+Q/XQ40/WZM4pgu6xi4fRCiobX1OKmPq4CrQ==';
}
