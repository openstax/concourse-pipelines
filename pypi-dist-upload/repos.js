module.exports.repos = [
  {
    githubRepo: 'openstax/cnx-archive',
    setupOptions: 'bdist_wheel',
    pythonImageTag: '2.7'
  },
  {
    githubRepo: 'openstax/cnx-archive',
    setupOptions: 'bdist_wheel',
    pythonImageTag: '3'
  },
  {
    githubRepo: 'openstax/cnx-common',
    setupOptions: 'bdist_wheel --universal',
    pythonImageTag: '3'
  },
  {
    githubRepo: 'openstax/cnx-db',
    setupOptions: 'bdist_wheel --universal',
    pythonImageTag: '2.7'
  },
  {
    githubRepo: 'openstax/cnx-easybake',
    setupOptions: 'bdist_wheel --universal',
    pythonImageTag: '2.7'
  },
  {
    githubRepo: 'openstax/cnx-epub',
    setupOptions: 'bdist_wheel --universal',
    pythonImageTag: '3'
  },
  {
    githubRepo: 'openstax/cnx-litezip',
    setupOptions: 'bdist_wheel',
    pythonImageTag: '3'
  },
  {
    githubRepo: 'openstax/cnx-publishing',
    setupOptions: 'bdist_wheel',
    pythonImageTag: '2.7'
  },
  {
    githubRepo: 'openstax/cnx-recipes',
    setupOptions: 'bdist_wheel --universal',
    pythonImageTag: '3'
  },
  {
    githubRepo: 'openstax/cnx-transforms',
    setupOptions: 'bdist_wheel --universal',
    pythonImageTag: '2.7'
  },
  {
    githubRepo: 'openstax/cnxml',
    setupOptions: 'bdist_wheel',
    pythonImageTag: '3'
  },
  {
    githubRepo: 'openstax/nebuchadnezzar',
    setupOptions: 'bdist_wheel',
    pythonImageTag: '3'
  },
  {
    githubRepo: 'openstax/rhaptos.cnxmlutils',
    setupOptions: 'bdist_wheel --universal',
    pythonImageTag: '2.7'
  },
]