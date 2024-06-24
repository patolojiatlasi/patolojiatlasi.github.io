document.addEventListener('DOMContentLoaded', function() {
    const specimenList = document.getElementById('specimens-list');
    const specimenDetails = document.getElementById('specimen-details');
    const specialtySelect = document.getElementById('specialtySelect');
    const organSelect = document.getElementById('organSelect');
    const categorySelect = document.getElementById('categorySelect');
    const searchInput = document.getElementById('searchInput');

    // Populate filters
    const specialties = [...new Set(specimensData.map(s => s.speciality).filter(Boolean))];
    specialtySelect.innerHTML += specialties.map(s => `<option value="${s}">${s}</option>`).join('');

    const organs = [...new Set(specimensData.map(s => s.organEN).filter(Boolean))];
    organSelect.innerHTML += organs.map(o => `<option value="${o}">${o}</option>`).join('');

    const categories = [...new Set(specimensData.flatMap(s => s.categoriesEN))];
    categorySelect.innerHTML += categories.map(c => `<option value="${c}">${c}</option>`).join('');

    function renderSpecimenList(specimens) {
        specimenList.innerHTML = specimens.map(s => `
            <div class="specimen" data-stainname="${s.stainname}">
                <h3>${s.titleEN}</h3>
                <p>${s.organEN || 'N/A'}</p>
                <p>Specialty: ${s.speciality || 'N/A'}</p>
                <img src="${s.screenshot}" alt="${s.titleEN}" width="100">
            </div>
        `).join('');

        specimenList.querySelectorAll('.specimen').forEach(el => {
            el.addEventListener('click', () => showSpecimenDetails(el.dataset.stainname));
        });
    }

    function showSpecimenDetails(stainname) {
        const specimen = specimensData.find(s => s.stainname === stainname);
        specimenDetails.innerHTML = `
            <h2>${specimen.titleEN} (${specimen.titleTR})</h2>
            <p>Organ: ${specimen.organEN} (${specimen.organTR})</p>
            <p>Specialty: ${specimen.speciality || 'N/A'}</p>
            <p>Authors: ${specimen.author.join(', ')}</p>
            <p>Date: ${specimen.date}</p>
            <p>Categories: ${specimen.categoriesEN.join(', ')}</p>
            <img src="${specimen.screenshot}" alt="${specimen.titleEN}">
            <p><a href="${specimen.url}" target="_blank">View Full Image</a></p>
            ${specimen.githubrepo ? `<p><a href="${specimen.githubrepo}" target="_blank">GitHub Repository</a></p>` : ''}
            ${specimen.youtube ? `<p><a href="${specimen.youtube}" target="_blank">YouTube Video</a></p>` : ''}
        `;
    }

    function filterSpecimens() {
        const specialty = specialtySelect.value;
        const organ = organSelect.value;
        const category = categorySelect.value;
        const searchTerm = searchInput.value.toLowerCase();

        const filtered = specimensData.filter(s =>
            (!specialty || s.speciality === specialty) &&
            (!organ || s.organEN === organ) &&
            (!category || s.categoriesEN.includes(category)) &&
            (s.titleEN.toLowerCase().includes(searchTerm) || s.titleTR.toLowerCase().includes(searchTerm))
        );
        renderSpecimenList(filtered);
    }

    specialtySelect.addEventListener('change', filterSpecimens);
    organSelect.addEventListener('change', filterSpecimens);
    categorySelect.addEventListener('change', filterSpecimens);
    searchInput.addEventListener('input', filterSpecimens);

    // Initial render
    renderSpecimenList(specimensData);
});
