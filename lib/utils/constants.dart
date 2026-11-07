class AppConstants {
  // Check which domains your school actually uses and edit this list
  static const allowedDomains = ['alustudent.com', 'alueducation.com'];

  static const categories = [
    'Facilities',
    'Water',
    'Electricity',
    'Furniture',
    'Sanitation',
    'Safety',
  ];

  static const statuses = [
    'Submitted',
    'Under Review',
    'In Progress',
    'Resolved',
  ];

  static const photoUploadEnabled = true;

  // Cloudinary (free image hosting, unsigned uploads)
  static const cloudinaryCloudName = 'ljvhmiyp';
  static const cloudinaryPreset = 'campus_unsigned';
}
