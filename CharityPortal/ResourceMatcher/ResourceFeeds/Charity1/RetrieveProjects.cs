using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Net;
using CharityPortal.Data;
using System.Web.Script.Serialization;

namespace ResourceMatcher.ResourceFeeds.Charity1
{
    public class RetrieveProjects
    {
        private static Organization organisation = null;

        private static string CharityName = "Big Charity 1";
        private static string CharityEmail = "dave@davehawes.com";

        public static Organization GetOrganisation
        {
            get
            {
                if (organisation == null)
                {
                    organisation = _context.Organizations.FirstOrDefault(org => org.Name == CharityName);
                    if (organisation == null)
                    {
                        organisation = new Organization();
                        organisation.Name = CharityName;
                        organisation.ContactEmail = CharityEmail;
                        _context.AddToOrganizations(organisation);
                        _context.SaveChanges();
                    }
                }

                return organisation;
            }
        }



        public static void Execute()
        {
            var client = new WebClient();
            var result = client.DownloadString("http://www.skillbook.co.uk/ca/data/project.json.html");
            var j = new JavaScriptSerializer();
            var result2 = j.Deserialize<ProjectPoco[]>(result);

            Project project = null;

            foreach (var item in result2)
            {
                project = _context.Projects.FirstOrDefault(proj => proj.ExternalId == item.ProjectId);

                if (project == null)
                {
                    project = new Project();
                    project.AdminOrganization = GetOrganisation;

                    project.Location = new Location();

                    _context.AddToProjects(project);
                }


                project.Location.Longitude = RandomNumber(40, 55);
                project.Location.Latitude = RandomNumber(40, 55);
                project.Location.Address = "Playgound Central";

                project.Name = item.Name;
                project.ExternalId = item.ProjectId;
                project.Description = item.Description;
                
                
            }

            _context.SaveChanges();
        }

        private static int RandomNumber(int min, int max)
        {
            Random random = new Random();
            return random.Next(min, max);
        }

        private static readonly CharityPortal.Data.DataContextContainer _context = new CharityPortal.Data.DataContextContainer();

    }
}