<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.shopsphere.model.Coupon,com.shopsphere.model.User,java.util.List,com.shopsphere.model.Address" %>
<% String ctx = request.getContextPath(); %>
<% User loggedInUser = (User) session.getAttribute("loggedInUser"); %>
<% Coupon checkoutCoupon = (Coupon) request.getAttribute("checkoutCoupon"); %>
<% String checkoutMessage = (String) session.getAttribute("checkoutMessage"); %>
<% List<Address> savedAddresses = (List<Address>) request.getAttribute("savedAddresses"); %>
<% String rzpKey = (String) request.getAttribute("razorpayKeyId"); %>
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>Checkout — Trendify Boutique</title>
    <link rel="stylesheet" href="<%= ctx %>/assets/css/app.css">
    <script src="https://checkout.razorpay.com/v1/checkout.js"></script>
    <style>
        .address-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: 14px; margin-bottom: 20px; }
        .addr-card { background: var(--surface); border: 1px solid var(--line); border-radius: 10px; padding: 16px; cursor: pointer; transition: all 0.25s ease; position: relative; }
        .addr-card:hover { border-color: var(--accent-light); background: var(--surface-2); }
        .addr-card.active { border-color: var(--accent); background: var(--surface-2); box-shadow: var(--shadow-sm); }
        .addr-card .addr-icon { width: 32px; height: 32px; border-radius: 50%; background: var(--bg-soft); color: var(--accent); display: flex; align-items: center; justify-content: center; font-size: 14px; margin-bottom: 10px; }
        .addr-card .addr-line { font-size: 13px; font-weight: 600; color: var(--text); margin-bottom: 4px; line-height: 1.4; word-break: break-word; }
        .addr-card .addr-sub { font-size: 11px; color: var(--muted); }
        .addr-card .addr-check { position: absolute; top: 14px; right: 14px; width: 18px; height: 18px; border-radius: 50%; border: 1px solid var(--line); display: flex; align-items: center; justify-content: center; font-size: 10px; color: transparent; }
        .addr-card.active .addr-check { background: var(--accent); border-color: var(--accent); color: #FAF7F2; font-weight: bold; }
        
        .mapbox-suggestions { position: absolute; top: 100%; left: 0; right: 0; background: var(--surface); border: 1px solid var(--line); border-radius: 8px; z-index: 99; max-height: 200px; overflow-y: auto; box-shadow: var(--shadow-md); display: none; }
        .mapbox-item { padding: 10px 14px; font-size: 12px; color: var(--text); cursor: pointer; border-bottom: 1px solid var(--line-soft); }
        .mapbox-item:hover { background: var(--surface-2); color: var(--accent); }

        .pay-option { display: flex; align-items: center; gap: 14px; padding: 16px; background: var(--surface); border: 1px solid var(--line); border-radius: 10px; margin-bottom: 12px; cursor: pointer; transition: all 0.2s ease; }
        .pay-option:hover, .pay-option.active { border-color: var(--accent); background: var(--surface-2); }
        .pay-option input[type="radio"] { accent-color: var(--accent); width: 18px; height: 18px; flex-shrink: 0; }
    </style>
</head>
<body>
<header class="nav-header">
    <div class="container nav-inner">
        <a class="brand-logo" href="<%= ctx %>/">Trendify</a>
        <span class="eyebrow">SECURE CHECKOUT</span>
        <a class="btn ghost" href="<%= ctx %>/cart">Back to bag</a>
    </div>
</header>
<main class="container form-shell">
    <div class="card">
        <span class="eyebrow">01 DELIVERY · 02 ORDER · 03 PAYMENT</span>
        <h1 class="form-title">Complete your order.</h1>
        <p class="muted">Select your delivery address and preferred payment method.</p>

        <% if (checkoutMessage != null && !checkoutMessage.isBlank()) { %>
            <div class="notice" style="margin-top:16px;"><%= checkoutMessage %></div>
            <% session.removeAttribute("checkoutMessage"); %>
        <% } %>

        <div class="summary-box" style="margin-top:20px;">
            <div><span>Subtotal</span><strong>₹${cartTotal}</strong></div>
            <div><span>Discount</span><strong>- ₹${couponDiscount}</strong></div>
            <div><span>Payable Total</span><strong style="color:var(--accent,#d8c8a8);">₹${payableTotal}</strong></div>
        </div>

        <!-- Coupon Form -->
        <form method="post" action="<%= ctx %>/checkout" class="coupon-form" style="margin-top:16px;">
    <input type="hidden" name="_csrf" value="${csrfToken}" />
            <input name="couponCode" placeholder="Coupon code" value="<%= checkoutCoupon != null ? checkoutCoupon.getCode() : "" %>">
            <button type="submit" name="action" value="applyCoupon" class="btn secondary">Apply</button>
            <% if (checkoutCoupon != null) { %>
                <button type="submit" name="action" value="removeCoupon" class="btn secondary">Remove</button>
            <% } %>
        </form>
        <% if (checkoutCoupon != null) { %>
            <p class="muted" style="font-size:12px; margin-top:6px;">Applied coupon: <strong><%= checkoutCoupon.getCode() %></strong></p>
        <% } %>

        <!-- Main Order Form -->
        <form id="checkoutForm" method="post" action="<%= ctx %>/checkout" style="margin-top:24px;">
    <input type="hidden" name="_csrf" value="${csrfToken}" />
            <input type="hidden" name="razorpay_payment_id" id="rzpPaymentId" value="">
            <input type="hidden" name="addressId" id="selectedAddressId" value="">
            
            <h3 style="font-size:14px; font-weight:600; text-transform:uppercase; letter-spacing:0.08em; color:var(--accent); margin-bottom:14px;">1. Delivery Address</h3>

            <% if (savedAddresses != null && !savedAddresses.isEmpty()) { %>
                <p style="font-size:11px; color:#a6a19a; margin-bottom:10px;">Select from your saved addresses or enter a new one:</p>
                <div class="address-grid">
                    <% for (int i = 0; i < savedAddresses.size(); i++) { 
                        Address addr = savedAddresses.get(i); 
                    %>
                        <div class="addr-card <%= i == 0 ? "active" : "" %>" 
                             onclick="selectSavedAddress('<%= addr.getAddressId() %>', '<%= addr.getAddressLine().replace("'", "\\'") %>', '<%= addr.getCity().replace("'", "\\'") %>', '<%= addr.getState().replace("'", "\\'") %>', '<%= addr.getPincode().replace("'", "\\'") %>', this)">
                            <div class="addr-check">✓</div>
                            <div class="addr-icon">📍</div>
                            <div class="addr-line"><%= addr.getAddressLine() %></div>
                            <div class="addr-sub"><%= addr.getCity() %>, <%= addr.getState() %> - <%= addr.getPincode() %></div>
                        </div>
                    <% } %>
                    <div class="addr-card" onclick="selectNewAddress(this)">
                        <div class="addr-check">✓</div>
                        <div class="addr-icon" style="background:rgba(255,255,255,0.06); color:#fff;">+</div>
                        <div class="addr-line" style="color:var(--accent,#d8c8a8);">Enter New Address</div>
                        <div class="addr-sub">Add custom delivery location below</div>
                    </div>
                </div>
            <% } %>

            <div id="addressFormFields" style="background:#141414; border:1px solid rgba(255,255,255,0.12); border-radius:8px; padding:20px; margin-bottom:24px;">
                <div class="field" style="position:relative;">
                    <label>Street Address / Landmark</label>
                    <textarea name="addressLine" id="inputAddressLine" rows="3" maxlength="255" required placeholder="House/Flat No., Building, Street, Area" oninput="fetchMapboxSuggestions(this.value)"></textarea>
                    <div id="mapboxSuggestions" class="mapbox-suggestions"></div>
                </div>
                <div style="display:grid; grid-template-columns: 1fr 1fr; gap:12px;">
                    <div class="field">
                        <label>City</label>
                        <input name="city" id="inputCity" maxlength="100" required placeholder="New Delhi">
                    </div>
                    <div class="field">
                        <label>State</label>
                        <input name="state" id="inputState" maxlength="100" required placeholder="Delhi">
                    </div>
                </div>
                <div class="field">
                    <label>Pincode</label>
                    <input name="pincode" id="inputPincode" pattern="[0-9]{6}" inputmode="numeric" maxlength="6" required placeholder="110001">
                </div>
            </div>

            <h3 style="font-size:14px; font-weight:600; text-transform:uppercase; letter-spacing:0.08em; color:var(--accent); margin-top:28px; margin-bottom:14px;">2. Payment Method</h3>

            <label class="pay-option active" onclick="togglePaymentChoice(this)">
                <input type="radio" name="paymentMethod" value="COD" checked>
                <div>
                    <strong style="display:block; color:#f3efe7; font-size:13px;">Cash on Delivery (COD)</strong>
                    <span style="font-size:11px; color:#a6a19a;">Pay with cash when your package is delivered to your doorstep.</span>
                </div>
            </label>

            <label class="pay-option" onclick="togglePaymentChoice(this)">
                <input type="radio" name="paymentMethod" value="RAZORPAY">
                <div>
                    <strong style="display:block; color:#f3efe7; font-size:13px;">Razorpay Online (UPI / Credit & Debit Cards / NetBanking)</strong>
                    <span style="font-size:11px; color:#a6a19a;">Instant secure online payment with Razorpay Test Gateway.</span>
                </div>
            </label>

            <button type="button" id="paySubmitBtn" onclick="handleCheckoutSubmit()" style="width:100%; margin-top:24px; padding:16px; font-size:13px; font-weight:bold; letter-spacing:1px; text-transform:uppercase;">
                Place Order (₹${payableTotal})
            </button>
        </form>
    </div>
</main>

<script>
    // Initialize first saved address if available
    window.addEventListener('DOMContentLoaded', () => {
        <% if (savedAddresses != null && !savedAddresses.isEmpty()) { 
            Address first = savedAddresses.get(0);
        %>
            selectSavedAddress('<%= first.getAddressId() %>', '<%= first.getAddressLine().replace("'", "\\'") %>', '<%= first.getCity().replace("'", "\\'") %>', '<%= first.getState().replace("'", "\\'") %>', '<%= first.getPincode().replace("'", "\\'") %>', document.querySelector('.addr-card'));
        <% } %>
    });

    function selectSavedAddress(id, line, city, state, pincode, cardEl) {
        document.querySelectorAll('.addr-card').forEach(c => c.classList.remove('active'));
        if (cardEl) cardEl.classList.add('active');

        document.getElementById('selectedAddressId').value = id;
        document.getElementById('inputAddressLine').value = line;
        document.getElementById('inputCity').value = city;
        document.getElementById('inputState').value = state;
        document.getElementById('inputPincode').value = pincode;
    }

    function selectNewAddress(cardEl) {
        document.querySelectorAll('.addr-card').forEach(c => c.classList.remove('active'));
        if (cardEl) cardEl.classList.add('active');

        document.getElementById('selectedAddressId').value = "";
        document.getElementById('inputAddressLine').value = "";
        document.getElementById('inputCity').value = "";
        document.getElementById('inputState').value = "";
        document.getElementById('inputPincode').value = "";
        document.getElementById('inputAddressLine').focus();
    }

    function togglePaymentChoice(el) {
        document.querySelectorAll('.pay-option').forEach(item => item.classList.remove('active'));
        el.classList.add('active');
        const radio = el.querySelector('input[type="radio"]');
        if (radio) radio.checked = true;
    }

    // Mapbox / OpenStreetMap Location Search Suggestion Engine
    let mapboxTimer;
    function fetchMapboxSuggestions(query) {
        clearTimeout(mapboxTimer);
        const container = document.getElementById('mapboxSuggestions');
        if (!query || query.trim().length < 3) {
            container.style.display = 'none';
            return;
        }

        mapboxTimer = setTimeout(() => {
            fetch('https://nominatim.openstreetmap.org/search?format=json&countrycodes=in&addressdetails=1&limit=5&q=' + encodeURIComponent(query))
                .then(r => r.json())
                .then(data => {
                    if (!data || data.length === 0) {
                        container.style.display = 'none';
                        return;
                    }
                    container.innerHTML = '';
                    data.forEach(item => {
                        const div = document.createElement('div');
                        div.className = 'mapbox-item';
                        div.innerHTML = '📍 ' + item.display_name;
                        div.onclick = () => applyMapboxAddress(item);
                        container.appendChild(div);
                    });
                    container.style.display = 'block';
                })
                .catch(() => { container.style.display = 'none'; });
        }, 300);
    }

    function applyMapboxAddress(item) {
        const addr = item.address || {};
        const line = (addr.road || addr.suburb || addr.neighbourhood || item.display_name.split(',')[0] || "").trim();
        const city = (addr.city || addr.town || addr.village || addr.county || "").trim();
        const state = (addr.state || "").trim();
        const pincode = (addr.postcode || "").trim();

        if (line) document.getElementById('inputAddressLine').value = item.display_name;
        if (city) document.getElementById('inputCity').value = city;
        if (state) document.getElementById('inputState').value = state;
        if (pincode) document.getElementById('inputPincode').value = pincode;

        document.getElementById('mapboxSuggestions').style.display = 'none';
    }

    document.addEventListener('click', (e) => {
        if (!e.target.closest('#inputAddressLine') && !e.target.closest('#mapboxSuggestions')) {
            document.getElementById('mapboxSuggestions').style.display = 'none';
        }
    });

    function handleCheckoutSubmit() {
        const form = document.getElementById('checkoutForm');
        const addrLine = document.getElementById('inputAddressLine').value.trim();
        const city = document.getElementById('inputCity').value.trim();
        const state = document.getElementById('inputState').value.trim();
        const pincode = document.getElementById('inputPincode').value.trim();

        if (!addrLine || !city || !state || !pincode) {
            alert("Please complete your delivery address details.");
            return;
        }

        const selectedMethod = form.querySelector('input[name="paymentMethod"]:checked').value;
        const total = "${payableTotal}";

        if (selectedMethod === 'RAZORPAY') {
            const options = {
                "key": "<%= rzpKey != null ? rzpKey : "rzp_test_TlXJYK6hDkOsvX" %>",
                "amount": Math.round(parseFloat(total) * 100),
                "currency": "INR",
                "name": "Trendify Luxury Boutique",
                "description": "Bespoke Order Payment",
                "handler": function (response) {
                    document.getElementById('rzpPaymentId').value = response.razorpay_payment_id || "pay_test_success";
                    form.submit();
                },
                "prefill": {
                    "name": "<%= loggedInUser != null ? loggedInUser.getName() : "" %>",
                    "email": "<%= loggedInUser != null ? loggedInUser.getEmail() : "" %>"
                },
                "theme": {
                    "color": "#9E7D52"
                }
            };
            try {
                const rzp = new Razorpay(options);
                rzp.open();
            } catch (e) {
                console.error("Razorpay error:", e);
                form.submit();
            }
        } else {
            form.submit();
        }
    }
</script>

<footer class="main-footer">
    <div class="container">
        <div class="footer-bottom">
            <span>© 2026 Trendify Boutique Ltd.</span>
            <a href="<%= ctx %>/products">Continue shopping</a>
        </div>
    </div>
</footer>
</body>
</html>