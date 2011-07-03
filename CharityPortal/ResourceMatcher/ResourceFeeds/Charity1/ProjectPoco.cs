using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ResourceMatcher.ResourceFeeds.Charity1
{
    public class ProjectPocos : List<ProjectPoco>
    {

    }

    public class ProjectPoco
    {
        public string Name { get; set; }
        public string ProjectId { get; set; }
        public string SummaryOfProject { get; set; }
        public string ProjectType { get; set; }
        public string TargetGroup { get; set; }

        public string Description
        {
            get
            {
                return string.Format(
                    "Project Type: {0}. - TargetGroup {1}. Summary Of Project {2}",
                    ProjectType,
                    TargetGroup,
                    SummaryOfProject);
            }
        }
    }
}
