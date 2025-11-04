#!/bin/bash

# Seed Database Script - Populate with Sample Data
# Creates a diverse set of professionals for frontend showcase

BASE_URL="http://localhost:8000/api"
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "======================================"
echo "Seeding NewtonX Database"
echo "======================================"
echo ""

echo -e "${BLUE}Creating sample professionals...${NC}"
echo ""

# Bulk insert all sample data
curl -s -X POST "$BASE_URL/professionals/bulk" \
  -H "Content-Type: application/json" \
  -d '[
    {
      "full_name": "Sarah Johnson",
      "email": "sarah.johnson@techcorp.com",
      "phone": "+1 555-101-1001",
      "company_name": "TechCorp Industries",
      "job_title": "VP of Engineering",
      "source": "direct"
    },
    {
      "full_name": "Michael Chen",
      "email": "michael.chen@innovate.com",
      "phone": "+1 555-102-1002",
      "company_name": "Innovate Solutions",
      "job_title": "Senior Product Manager",
      "source": "direct"
    },
    {
      "full_name": "Emily Rodriguez",
      "email": "emily.r@designstudio.com",
      "phone": "+1 555-103-1003",
      "company_name": "Design Studio Pro",
      "job_title": "Creative Director",
      "source": "direct"
    },
    {
      "full_name": "James Wilson",
      "email": "james.wilson@consulting.com",
      "phone": "+1 555-104-1004",
      "company_name": "Wilson Consulting Group",
      "job_title": "Managing Partner",
      "source": "partner"
    },
    {
      "full_name": "Lisa Thompson",
      "email": "lisa.t@partners.com",
      "phone": "+1 555-105-1005",
      "company_name": "Global Partners LLC",
      "job_title": "Chief Strategy Officer",
      "source": "partner"
    },
    {
      "full_name": "Robert Martinez",
      "email": "robert.m@ventures.com",
      "phone": "+1 555-106-1006",
      "company_name": "Venture Capital Partners",
      "job_title": "Investment Director",
      "source": "partner"
    },
    {
      "full_name": "Jennifer Lee",
      "email": "jennifer.lee@company.com",
      "phone": "+1 555-107-1007",
      "company_name": "Internal Operations",
      "job_title": "Operations Manager",
      "source": "internal"
    },
    {
      "full_name": "David Anderson",
      "email": "david.anderson@company.com",
      "phone": "+1 555-108-1008",
      "company_name": "Internal HR",
      "job_title": "HR Director",
      "source": "internal"
    },
    {
      "full_name": "Amanda Foster",
      "email": "amanda.f@startup.io",
      "phone": "+1 555-109-1009",
      "company_name": "Startup Innovations",
      "job_title": "Co-Founder & CEO",
      "source": "direct"
    },
    {
      "full_name": "Christopher Brown",
      "email": "chris.brown@finance.com",
      "phone": "+1 555-110-1010",
      "company_name": "Finance Solutions Inc",
      "job_title": "CFO",
      "source": "partner"
    },
    {
      "full_name": "Michelle Davis",
      "email": "michelle.d@marketing.com",
      "phone": "+1 555-111-1011",
      "company_name": "Marketing Dynamics",
      "job_title": "CMO",
      "source": "direct"
    },
    {
      "full_name": "Daniel Kim",
      "email": "daniel.kim@software.com",
      "phone": "+1 555-112-1012",
      "company_name": "Software Solutions Co",
      "job_title": "Lead Architect",
      "source": "direct"
    },
    {
      "full_name": "Rachel Green",
      "email": "rachel.green@agency.com",
      "phone": "+1 555-113-1013",
      "company_name": "Creative Agency",
      "job_title": "Account Director",
      "source": "partner"
    },
    {
      "full_name": "Thomas White",
      "email": "thomas.w@research.org",
      "phone": "+1 555-114-1014",
      "company_name": "Research Institute",
      "job_title": "Principal Researcher",
      "source": "internal"
    },
    {
      "full_name": "Patricia Moore",
      "email": "patricia.moore@legal.com",
      "phone": "+1 555-115-1015",
      "company_name": "Moore Legal Associates",
      "job_title": "Senior Partner",
      "source": "partner"
    },
    {
      "full_name": "Kevin Taylor",
      "email": "kevin.t@cloud.com",
      "phone": "+1 555-116-1016",
      "company_name": "Cloud Systems Inc",
      "job_title": "VP of Infrastructure",
      "source": "direct"
    },
    {
      "full_name": "Nicole Harris",
      "email": "nicole.harris@data.com",
      "phone": "+1 555-117-1017",
      "company_name": "Data Analytics Corp",
      "job_title": "Chief Data Officer",
      "source": "direct"
    },
    {
      "full_name": "Brian Clark",
      "email": "brian.clark@security.com",
      "phone": "+1 555-118-1018",
      "company_name": "CyberSecurity Experts",
      "job_title": "Security Architect",
      "source": "partner"
    },
    {
      "full_name": "Laura Adams",
      "email": "laura.adams@company.com",
      "phone": "+1 555-119-1019",
      "company_name": "Internal Training",
      "job_title": "Training Director",
      "source": "internal"
    },
    {
      "full_name": "Steven Wright",
      "email": "steven.w@blockchain.com",
      "phone": "+1 555-120-1020",
      "company_name": "Blockchain Ventures",
      "job_title": "CTO",
      "source": "direct"
    },
    {
      "full_name": "Angela Turner",
      "email": "angela.turner@ecommerce.com",
      "phone": "+1 555-121-1021",
      "company_name": "E-Commerce Platform",
      "job_title": "VP of Product",
      "source": "direct"
    },
    {
      "full_name": "Mark Phillips",
      "email": "mark.p@advisory.com",
      "phone": "+1 555-122-1022",
      "company_name": "Advisory Services Group",
      "job_title": "Senior Advisor",
      "source": "partner"
    },
    {
      "full_name": "Sandra Campbell",
      "email": "sandra.c@company.com",
      "phone": "+1 555-123-1023",
      "company_name": "Internal Compliance",
      "job_title": "Compliance Officer",
      "source": "internal"
    },
    {
      "full_name": "Jason Mitchell",
      "email": "jason.mitchell@ai.com",
      "phone": "+1 555-124-1024",
      "company_name": "AI Innovations Lab",
      "job_title": "Machine Learning Lead",
      "source": "direct"
    },
    {
      "full_name": "Karen Roberts",
      "email": "karen.roberts@healthcare.com",
      "phone": "+1 555-125-1025",
      "company_name": "Healthcare Tech Solutions",
      "job_title": "VP of Clinical Operations",
      "source": "partner"
    }
  ]' | json_pp

echo ""
echo -e "${GREEN}Database seeded successfully!${NC}"
echo ""
echo "Created 25 sample professionals:"
echo "  - 11 from 'direct' source"
echo "  - 9 from 'partner' source"
echo "  - 5 from 'internal' source"
echo ""
echo "You can now view them in the frontend at:"
echo "http://localhost:5173/professionals"
